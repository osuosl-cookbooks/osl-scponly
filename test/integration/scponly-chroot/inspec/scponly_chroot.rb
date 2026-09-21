# InSpec test for recipe osl-scponly::default

# The InSpec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

require_relative '../../helpers/inspec/helpers_spec'

altroot = '/var/lib/chroots'
accounts = %w(scponly_test_chroot scponly_test_chroot2)

accounts.each do |account|
  scponly_test(account, "#{altroot}/home/#{account}")

  describe user(account) do
    it { should exist }
    # '//' is scponlyc's chroot-point delimiter; without it the account is
    # chrooted into its own empty home and every transfer fails.
    its('home') { should cmp "#{altroot}//home/#{account}" }
    its('shell') { should cmp '/usr/sbin/scponlyc' }
    its('group') { should cmp account }
  end

  # Every chrooted account needs its own line here, with a home that is absolute
  # inside the jail. Only the first account used to land.
  describe file "#{altroot}/etc/passwd" do
    its('content') { should match %r{^#{account}:x:\d+:\d+::/home/#{account}:/usr/sbin/scponlyc$} }
  end
end

%w(bin etc lib64 usr).each do |d|
  describe directory("#{altroot}/#{d}") do
    it { should exist }
  end
end
