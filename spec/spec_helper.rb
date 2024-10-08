require 'chefspec'
require 'chefspec/berkshelf'

ALMA_8 = {
  platform: 'almalinux',
  version: '8',
}.freeze
ALMA_9 = {
  platform: 'almalinux',
  version: '9',
}.freeze

ALL_PLATFORMS = [
  ALMA_8,
  ALMA_9,
].freeze

RSpec.configure do |config|
  config.log_level = :warn
end

shared_examples 'scponly_user' do |user, home|
  it { expect(chef_run).to create_group(user) }

  it do
    expect(chef_run).to create_directory(home).with(
      mode: '0550',
      owner: 'root',
      group: user
    )
  end

  it do
    expect(chef_run).to create_directory("#{home}/write").with(
      owner: 'root',
      group: 'scponly',
      mode: '0770',
      recursive: true
    )
  end

  it do
    expect(chef_run).to modify_group('scponly').with(
      members: [ user ]
    )
  end

  it do
    expect(chef_run).to create_directory("#{home}/.ssh").with(
      mode: '0550',
      owner: user,
      group: user
    )
  end

  it do
    expect(chef_run).to create_file("#{home}/.ssh/authorized_keys").with(
      mode: '0400',
      owner: user,
      group: user
    )
  end

  it do
    expect(chef_run).to create_file("#{home}/.ssh/id_rsa-scponly_user-#{user}").with(
      mode: '0400',
      owner: user,
      group: user,
      sensitive: true
    )
  end
end
