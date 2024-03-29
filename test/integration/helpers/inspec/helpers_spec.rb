def scponly_test(user, home)
  describe group(user) do
    it { should exist }
  end

  describe directory(home) do
    it { should exist }
    its('mode') { should cmp '0550' }
  end

  describe directory("#{home}/write") do
    it { should exist }
    its('mode') { should cmp '0770' }
    its('owner') { should cmp 'root' }
    its('group') { should cmp 'scponly' }
  end

  describe directory("#{home}/.ssh") do
    it { should exist }
    its('mode') { should cmp '0550' }
  end

  describe file("#{home}/.ssh/authorized_keys") do
    it { should exist }
    its('mode') { should cmp '0400' }
    its('owner') { should cmp user }
  end

  describe file("#{home}/.ssh/id_rsa-scponly_user-#{user}") do
    it { should exist }
    its('mode') { should cmp '0400' }
    its('owner') { should cmp user }
  end

  describe file('/tmp/testfile.img') do
    it { should exist }
    its('mode') { should cmp '0644' }
    its('owner') { should cmp user }
    its('group') { should cmp user }
  end

  describe file("#{home}/write/testfile.img") do
    it { should_not exist }
  end

  describe port('0.0.0.0', 22) do
    it { should be_listening }
  end

  scp_command = "sudo scp -vvv -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i \
  #{home}/.ssh/id_rsa-scponly_user-#{user} /tmp/testfile.img #{user}@127.0.0.1:/home/#{user}/write/testfile.img"

  describe command(scp_command) do
    its('exit_status') { should cmp 0 }
  end

  describe command("cmp #{home}/write/testfile.img /tmp/testfile.img") do
    its('exit_status') { should cmp 0 }
  end

  describe command("rm #{home}/write/testfile.img") do
    its('exit_status') { should cmp 0 }
  end
end
