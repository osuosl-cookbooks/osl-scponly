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

      it { expect(chef_run).to include_recipe('osl-scponly::default') }

      it do
        expect(chef_run).to create_scponly_user('scponly_test_chroot').with(
          write_dir: 'write',
          chroot: true
        )
      end

      it { expect(chef_run).to create_directory('/home/chroot/home/scponly_test_chroot') }

      it do
        expect(chef_run).to create_user('scponly_test_chroot').with(
          gid: 'scponly',
          home: '/home/chroot/home/scponly_test_chroot',
          manage_home: true,
          shell: '/usr/sbin/scponlyc'
        )
      end

      it do
        expect(chef_run).to create_directory('/home/chroot/home/scponly_test_chroot/write').with(
          owner: 'root',
          group: 'scponly',
          mode: '0770',
          recursive: true
        )
      end

      it { expect(chef_run).to create_directory('/usr/share/libexec/') }

      it do
        expect(chef_run).to create_cookbook_file('/usr/share/libexec/scponly-chroot.sh').with(
          source: 'scponly-chroot.sh',
          mode: '0755'
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
        /usr/bin/scp
        /usr/sbin/scponlyc
      )
      it do
        expect(chef_run).to run_execute('Build chroot jail').with(
          command: "bash /usr/share/libexec/scponly-chroot.sh /home/chroot #{binaries.join(' ')}",
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
        expect(chef_run).to run_bash('Chroot /etc/passwd').with(
          code: 'cat /etc/passwd | grep scponly_test_chroot > /home/chroot/etc/passwd'
        )
      end

      it { expect(chef_run).to create_group('scponly_test_chroot').with(members: ['scponly_test_chroot']) }

      it { expect(chef_run).to create_directory('/home/chroot/home/scponly_test_chroot').with(mode: '0550') }

      it do
        expect(chef_run).to create_directory('/home/chroot/home/scponly_test_chroot/.ssh').with(
          mode: '0550',
          owner: 'scponly_test_chroot',
          group: 'scponly_test_chroot'
        )
      end

      it do
        expect(chef_run).to create_file('/home/chroot/home/scponly_test_chroot/.ssh/authorized_keys').with(
          mode: '0400',
          owner: 'scponly_test_chroot',
          group: 'scponly_test_chroot'
        )
      end

      it do
        expect(chef_run).to create_file('/home/chroot/home/scponly_test_chroot/.ssh/id_rsa-scponly_user-scponly_test_chroot').with(
          mode: '0400',
          owner: 'scponly_test_chroot',
          group: 'scponly_test_chroot',
          sensitive: true
        )
      end

      it do
        expect(chef_run).to run_execute('fallocate -l 10m /tmp/testfile.img').with(
          creates: '/tmp/testfile.img'
        )
      end

      it do
        expect(chef_run).to create_file('/tmp/testfile.img').with(
          owner: 'scponly_test_chroot',
          group: 'scponly_test_chroot'
        )
      end
    end
  end
end
