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

      include_examples 'scponly_user', 'scponly_test_chroot', "#{altroot}/home/scponly_test_chroot"

      it { expect(chef_run).to include_recipe('osl-scponly::default') }

      it do
        expect(chef_run).to create_scponly_user('scponly_test_chroot').with(
          write_dir: 'write',
          chroot: true
        )
      end

      it do
        expect(chef_run).to create_user('scponly_test_chroot').with(
          gid: 'scponly_test_chroot',
          home: "#{altroot}//home/scponly_test_chroot",
          manage_home: true,
          shell: '/usr/sbin/scponlyc'
        )
      end

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

      it do
        expect(chef_run).to run_execute("grep scponly_test_chroot /etc/passwd > #{altroot}/etc/passwd").with(
          creates: "#{altroot}/etc/passwd"
        )
      end
      it do
        expect(chef_run).to edit_filter_lines('/var/lib/chroots/etc/passwd')
          .with(
            filters: {
              substitute: [%r{/var/lib/chroots}, %r{/var/lib/chroots/}, ''],
            },
            sensitive: false
          )
      end
    end
  end
end
