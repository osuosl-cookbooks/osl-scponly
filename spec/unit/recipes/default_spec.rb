require_relative '../../spec_helper'

describe 'osl-scponly::default' do
  ALL_PLATFORMS.each do |p|
    context "#{p[:platform]} #{p[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(p).converge(described_recipe)
      end

      it { expect { chef_run }.to_not raise_error }

      it { expect(chef_run).to include_recipe('yum-epel') }

      it { expect(chef_run).to create_group('scponly').with(system: true) }
    end
  end
end
