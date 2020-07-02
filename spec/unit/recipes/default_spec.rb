require_relative '../../spec_helper'

describe 'osl-scponly::default' do
  ALL_PLATFORMS.each do |p|
    context "#{p[:platform]} #{p[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(p).converge(described_recipe)
      end

      it { expect { chef_run }.to_not raise_error }

      it { expect(chef_run).to include_recipe('yum-epel') }

      it { expect(chef_run).to install_package('scponly') }

      it do
        expect(chef_run).to create_file('/usr/sbin/scponlyc').with(
          mode: '4755'
        )
      end

      it { expect(chef_run).to create_group('scponly').with(system: true) }
      before do
        stub_command('grep scponly /etc/passwd')
      end
      it do
        expect(chef_run).to create_cookbook_file('/usr/libexec/scponly-chroot.sh').with(
          source: 'scponly-chroot.sh',
          mode: '0755'
        )
      end
    end
  end
end
