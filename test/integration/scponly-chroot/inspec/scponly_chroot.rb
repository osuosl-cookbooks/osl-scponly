# InSpec test for recipe osl-scponly::default

# The InSpec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

require_relative '../../helpers/inspec/helpers_spec'

altroot = '/var/lib/chroots'
scponly_test('scponly_test_chroot', "#{altroot}/home/scponly_test_chroot")

describe user('scponly_test_chroot') do
  it { should exist }
  its('home') { should cmp "#{altroot}//home/scponly_test_chroot" }
  its('shell') { should cmp '/usr/sbin/scponlyc' }
  its('group') { should cmp 'scponly_test_chroot' }
end

describe file '/var/lib/chroots/etc/passwd' do
  its('content') { should match %r{^scponly_test_chroot:x:(1000|1001|1002):(1000|1001|1002)::/home/scponly_test_chroot:/usr/sbin/scponlyc$} }
end

%w(bin etc lib64 usr).each do |d|
  describe directory("#{altroot}/#{d}") do
    it { should exist }
  end
end
