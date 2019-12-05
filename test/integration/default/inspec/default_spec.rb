# InSpec test for recipe osl-scponly::default

# The InSpec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

describe file('/etc/shells') do
  its('content') { should include '/usr/sbin/scponlyc' }
end

describe package('scponly') do
  it { should be_installed }
end

%w( scponly testuser ).each do |g|
  describe group(g) do
    it { should exist }
  end
end

describe user('testuser') do
  it { should exist }
  its('home') { should cmp '/home/testuser' }
  its('shell') { should cmp '/usr/sbin/scponlyc' }
end

describe directory('/home/testuser') do
  it { should exist }
  its('mode') { should cmp '0500' }
end

describe directory('/pub/upload') do
  it { should exist }
  its('mode') { should cmp '0770' }
  its('owner') { should cmp 'root' }
  its('group') { should cmp 'scponly' }
end

describe command('scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i /home/testuser/.ssh/id_rsa /tmp/testfile.img testuser@127.0.0.1:/pub/upload/testfile.img') do
  its('exit_status') { should cmp 0 }
end

describe command('cmp /pub/upload/testfile.img /tmp/testfile.img') do
  its('exit_status') { should cmp 0 }
end
