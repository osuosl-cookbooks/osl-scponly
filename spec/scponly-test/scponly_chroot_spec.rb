require 'spec_helper'

describe 'scponly-test::scponly_chroot' do
  ALL_PLATFORMS.each do |p|
    context "#{p[:platform]} #{p[:version]}" do
      let(:runner) do
        ChefSpec::SoloRunner.new(
          p.dup.merge(step_into: ['scponly_user'])
        )
      end
      let(:node) { runner.node }
      cached(:chef_run) { runner.converge(described_recipe) }

      it { expect { chef_run }.to_not raise_error }

      altroot = '/var/lib/chroots'

      it { expect(chef_run).to include_recipe('osl-scponly::default') }

      binaries = %w(
        /bin/chgrp
        /bin/chmod
        /bin/chown
        /bin/ln
        /bin/ls
        /bin/mkdir
        /bin/mv
        /bin/rm
        /bin/rmdir
        /bin/scp
        /usr/libexec/openssh/sftp-server
        /usr/sbin/scponlyc
      )
      it do
        expect(chef_run).to run_execute('Build chroot jail').with(
          command: "/usr/libexec/scponly-chroot.sh #{altroot} #{binaries.join(' ')}",
          creates: "#{altroot}/bin"
        )
      end

      %w(ld.so.cache ld.so.conf group).each do |c|
        it do
          expect(chef_run).to create_remote_file("#{altroot}/etc/#{c}").with(
            source: "file:///etc/#{c}"
          )
        end
      end

      # Nothing else forces the lazy `line` to evaluate, so a NoMethodError in
      # that closure would only ever surface during a real converge.
      it 'resolves the lazy jail passwd line inside the resource context' do
        fake = [
          "root:x:0:0:root:/root:/bin/bash\n",
          "scponly_test_chroot:x:1001:1001::#{altroot}//home/scponly_test_chroot:/usr/sbin/scponlyc\n",
        ]
        allow(::File).to receive(:readlines).and_call_original
        allow(::File).to receive(:readlines).with('/etc/passwd').and_return(fake)

        res = chef_run.find_resource(
          :append_if_no_line, "Add scponly_test_chroot to #{altroot}/etc/passwd"
        )
        expect(res.line).to eq(
          'scponly_test_chroot:x:1001:1001::/home/scponly_test_chroot:/usr/sbin/scponlyc'
        )
      end

      # Both accounts share one jail, so both must reach its passwd database.
      %w(scponly_test_chroot scponly_test_chroot2).each do |account|
        home = "#{altroot}/home/#{account}"

        include_examples 'scponly_user', account, home

        it do
          expect(chef_run).to create_scponly_user(account).with(
            write_dir: 'write',
            chroot: true
          )
        end

        # The '//' is scponlyc's chroot-point delimiter, not a stray slash.
        it do
          expect(chef_run).to create_user(account).with(
            gid: account,
            home: "#{altroot}//home/#{account}",
            manage_home: true,
            shell: '/usr/sbin/scponlyc'
          )
        end

        # Only `path` is asserted: `line` is lazy, and reading it would run the
        # helper against the workstation's own /etc/passwd.
        it do
          expect(chef_run).to edit_append_if_no_line("Add #{account} to #{altroot}/etc/passwd").with(
            path: "#{altroot}/etc/passwd",
            sensitive: false
          )
        end

        it do
          expect(chef_run).to run_execute("fallocate -l 10m /tmp/testfile-#{account}.img").with(
            creates: "/tmp/testfile-#{account}.img"
          )
        end

        it do
          expect(chef_run).to create_file("/tmp/testfile-#{account}.img").with(
            owner: account,
            group: account
          )
        end
      end
    end
  end
end
