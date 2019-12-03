# InSpec test for recipe osl-scponly::default

# The InSpec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

%w(wget gcc rsync openssh-clients).each do |p|
  describe package(p) do
    it { should be_installed }
  end
end

describe file('/opt/scponly-20110526.tgz') do
  it { should exist }
end

describe file('/opt/scponly-20110526') do
  it { should exist }
end

describe file('/etc/shells') do
  its('content') { should include '/usr/local/bin/scponly' }
end

describe group('scponly') do
  it { should exist }
end

describe user('testuser') do
  it { should exist }
  its('group') { should cmp 'scponly' }
  its('shell') { should cmp '/usr/local/bin/scponly' }
end

describe file('/pub/upload') do
  its('mode') { should cmp '0770' }
end

describe file('/home/testuser') do
  its('mode') { should cmp '0500' }
  it { should be_directory }
end
