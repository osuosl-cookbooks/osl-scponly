require_relative '../spec_helper.rb'

describe 'scponly-test::scponly' do
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
        expect(chef_run).to create_scponly_user('scponly_test').with(
          write_dir: 'write',
          chroot: false
        )
      end

      it do
        expect(chef_run).to create_user('scponly_test').with(
          gid: 'scponly',
          home: '/home/scponly_test',
          manage_home: true,
          shell: '/usr/bin/scponly'
        )
      end

      it do
        expect(chef_run).to create_directory('/home/scponly_test/write').with(
          owner: 'root',
          group: 'scponly',
          mode: '0770',
          recursive: true
        )
      end

      it { expect(chef_run).to create_group('scponly_test').with(members: ['scponly_test']) }

      it { expect(chef_run).to create_directory('/home/scponly_test').with(mode: '0550') }

      it do
        expect(chef_run).to create_directory('/home/scponly_test/.ssh').with(
          mode: '0550',
          owner: 'scponly_test',
          group: 'scponly_test'
        )
      end

      it do
        expect(chef_run).to create_file('/home/scponly_test/.ssh/authorized_keys').with(
          mode: '0400',
          owner: 'scponly_test',
          group: 'scponly_test'
        )
      end

      it do
        expect(chef_run).to create_file('/home/scponly_test/.ssh/id_rsa-scponly_user-scponly_test').with(
          mode: '0400',
          owner: 'scponly_test',
          group: 'scponly_test',
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
          owner: 'scponly_test',
          group: 'scponly_test'
        )
      end
    end
  end
end
