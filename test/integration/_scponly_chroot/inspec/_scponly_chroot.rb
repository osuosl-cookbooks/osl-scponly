# InSpec test for recipe osl-scponly::default

# The InSpec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

describe package('scponly') do
  it { should be_installed }
end

%w(sbin/scponlyc bin/scponly).each do |s|
  describe file('/etc/shells') do
    its('content') { should include "/usr/#{s}" }
  end
end

describe group('scponly') do
  it { should exist }
end

[
  ['chroot_testuser', 'sbin/scponlyc', 'testfilec'],
  ['testuser', 'bin/scponly', 'testfile'],
].each do |u, s, f|

  describe user(u) do
    it { should exist }
    its('home') { should cmp "/home/#{u}" }
    its('shell') { should cmp "/usr/#{s}" }
  end

  describe group(u) do
    it { should exist }
  end

  describe directory("/home/#{u}") do
    it { should exist }
    its('mode') { should cmp '0550' }
  end

  describe directory("/home/#{u}/write") do
    it { should exist }
    its('mode') { should cmp '0770' }
    its('owner') { should cmp 'root' }
    its('group') { should cmp 'scponly' }
  end

  describe directory("/home/#{u}/.ssh") do
    it { should exist }
    its('mode') { should cmp '0550' }
  end

  describe file("/home/#{u}/.ssh/authorized_keys") do
    it { should exist }
    its('mode') { should cmp '0400' }
  end

  describe file("/home/#{u}/.ssh/id_rsa-scponly_user-#{u}") do
    it { should exist }
    its('mode') { should cmp '0400'}
  end

  describe command("scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i /home/#{u}/.ssh/id_rsa-scponly_user-#{u} /tmp/#{f}.img #{u}@127.0.0.1:/home/#{u}/write/#{f}.img") do
    its('exit_status') { should cmp 0 }
  end

  describe command("cmp /home/#{u}/home/#{u}/write/#{f}.img /tmp/#{f}.img") do
    its('exit_status') { should cmp 0 }
  end
end

describe directory("/home/chroot_testuser/home/chroot_testuser/write") do
  it { should exist }
end
