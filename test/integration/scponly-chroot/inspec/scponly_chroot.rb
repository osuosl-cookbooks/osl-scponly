# InSpec test for recipe osl-scponly::default

# The InSpec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

require_relative '../../helpers/inspec/helpers_spec.rb'

scponly_test('scponly_test_chroot', '/home/chroot/home/scponly_test_chroot')

describe user('scponly_test_chroot') do
  it { should exist }
  its('home') { should cmp '/home/chroot//home/scponly_test_chroot' }
  its('shell') { should cmp '/usr/sbin/scponlyc' }
  its('group') { should cmp 'scponly_test_chroot' }
end

%w(bin etc lib64 usr).each do |d|
  describe directory("/home/chroot/#{d}") do
    it { should exist }
  end
end
