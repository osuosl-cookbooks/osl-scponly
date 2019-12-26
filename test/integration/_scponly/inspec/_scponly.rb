# InSpec test for recipe osl-scponly::default

# The InSpec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

describe user('scponly_test') do
  it { should exist }
  its('home') { should cmp '/home/scponly_test' }
  its('shell') { should cmp '/usr/bin/scponly' }
  its('group') { should cmp 'scponly' }
end

describe group('scponly_test') do
  it { should exist }
end

describe directory('/home/scponly_test') do
  it { should exist }
  its('mode') { should cmp '0550' }
end

describe directory('/home/scponly_test/write') do
  it { should exist }
  its('mode') { should cmp '0770' }
  its('owner') { should cmp 'root' }
  its('group') { should cmp 'scponly' }
end

describe directory('/home/scponly_test/.ssh') do
  it { should exist }
  its('mode') { should cmp '0550' }
end

describe file("/home/scponly_test/.ssh/authorized_keys") do
  it { should exist }
  its('mode') { should cmp '0400' }
end

describe file("/home/scponly_test/.ssh/id_rsa-scponly_user-scponly_test") do
  it { should exist }
  its('mode') { should cmp '0400'}
end

describe file('/tmp/testfile.img') do
  it { should exist }
  its('owner') { should cmp 'scponly_test' }
  its('group') { should cmp 'scponly_test' }
end

describe file('/home/scponly_test/write/testfile.img') do
  it { should_not exist }
end

describe command("scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i /home/scponly_test/.ssh/id_rsa-scponly_user-scponly_test /tmp/testfile.img scponly_test@127.0.0.1:/home/scponly_test/write/testfile.img") do
  its('exit_status') { should cmp 0 }
end

describe command("cmp /home/scponly_test/write/testfile.img /tmp/testfile.img") do
  its('exit_status') { should cmp 0 }
end
