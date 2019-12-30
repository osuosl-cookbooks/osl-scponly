# InSpec test for recipe osl-scponly::default

# The InSpec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

describe user('scponly_test_chroot') do
  it { should exist }
  its('home') { should cmp '/home/chroot//home/scponly_test_chroot' }
  its('shell') { should cmp '/usr/sbin/scponlyc' }
end

describe group('scponly_test_chroot') do
  it { should exist }
end

describe directory('/home/chroot/home/scponly_test_chroot') do
  it { should exist }
  its('mode') { should cmp '0550' }
end

describe directory('/home/chroot/home/scponly_test_chroot/write') do
  it { should exist }
  its('mode') { should cmp '0755' }
  its('owner') { should cmp 'root' }
  its('group') { should cmp 'scponly' }
end

describe directory('/home/chroot/home/scponly_test_chroot/.ssh') do
  it { should exist }
  its('mode') { should cmp '0550' }
end

describe file('/home/chroot/home/scponly_test_chroot/.ssh/authorized_keys') do
  it { should exist }
  its('mode') { should cmp '0400' }
end

describe file('/home/chroot/home/scponly_test_chroot/.ssh/id_rsa-scponly_user-scponly_test_chroot') do
  it { should exist }
  its('mode') { should cmp '0400' }
end

describe file('/tmp/testfile.img') do
  it { should exist }
  its('owner') { should cmp 'scponly_test_chroot' }
  its('group') { should cmp 'scponly_test_chroot' }
end

describe file('/home/chroot/home/scponly_test_chroot/write/testfile.img') do
  it { should_not exist }
end

%w(bin etc lib64 usr).each do |d|
  describe directory("/home/chroot/#{d}") do
    it { should exist }
  end
end

describe command('scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i /home/chroot/home/scponly_test_chroot/.ssh/id_rsa-scponly_user-scponly_test_chroot /tmp/testfile.img scponly_test_chroot@127.0.0.1:/home/chroot/home/scponly_test_chroot/write/testfile.img') do
  its('exit_status') { should cmp 0 }
  its('stderr') { should cmp 'asdf' }
end

describe command('cmp /home/chroot/home/scponly_test_chroot/write/testfile.img /tmp/testfile.img') do
  its('exit_status') { should cmp 0 }
end

describe directory('/home/chroot/home/chroot_testuser/write') do
  it { should exist }
end
