# InSpec test for recipe osl-scponly::default

# The InSpec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

%w(wget gcc rsync openssh-clients).each do |p|
  describe package(p) do
    it { should be_installed }
  end
end

%w(
  /opt/scponly-20110526.tgz
  /opt/scponly-20110526
  /usr/local/bin/scponly
  /usr/local/sbin/scponlyc
).each do |f|
  describe file(f) do
    it { should exist }
  end
end

describe file('/etc/shells') do
  its('content') { should include '/usr/local/bin/scponly' }
  its('content') { should include '/usr/local/sbin/scponlyc' }
end

%w(scponly testuser).each do |g|
  describe group(g) do
    it { should exist }
  end
end

describe user('testuser') do
  it { should exist }
  its('group') { should cmp 'scponly' }
  its('shell') { should cmp '/usr/local/bin/scponlyc' }
end

describe file('/pub/upload') do
  its('mode') { should cmp '0770' }
end

describe directory('/home/testuser') do
  its('mode') { should cmp '0500' }
end

describe directory('/home/testuser/.ssh') do
  its('mode') { should cmp '0500' }
  its('owner') { should cmp 'testuser' }
  its('group') { should cmp 'testuser' }
end

describe file('/home/testuser/.ssh/authorized_keys') do
  its('mode') { should cmp '0400' }
  its('owner') { should cmp 'testuser' }
  its('group') { should cmp 'testuser' }
end
