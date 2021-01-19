require_relative '../spec_helper'

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

      include_examples 'scponly_user', 'scponly_test', '/home/scponly_test'

      it { expect(chef_run).to include_recipe('osl-scponly::default') }

      it do
        expect(chef_run).to create_scponly_user('scponly_test').with(
          write_dir: 'write',
          chroot: false
        )
      end

      it do
        expect(chef_run).to create_user('scponly_test').with(
          gid: 'scponly_test',
          home: '/home/scponly_test',
          manage_home: true,
          shell: '/usr/bin/scponly'
        )
      end
    end
  end
end
