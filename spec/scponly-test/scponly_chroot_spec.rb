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

      include_examples 'scponly_user', 'scponly_test_chroot', '/home/chroot/home/scponly_test_chroot'

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
          home: '/home/chroot//home/scponly_test_chroot',
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
          command: "/usr/libexec/scponly-chroot.sh /home/chroot #{binaries.join(' ')}",
          creates: '/home/chroot/bin'
        )
      end

      %w(ld.so.cache ld.so.conf group).each do |c|
        it do
          expect(chef_run).to create_remote_file("/home/chroot/etc/#{c}").with(
            source: "file:///etc/#{c}"
          )
        end
      end

      it do
        expect(chef_run).to run_execute('grep scponly_test_chroot /etc/passwd > /home/chroot/etc/passwd').with(
          creates: '/home/chroot/etc/passwd'
        )
      end
    end
  end
end
