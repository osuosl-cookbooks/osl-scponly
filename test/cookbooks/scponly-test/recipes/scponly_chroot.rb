scponly_user 'scponly_test_chroot' do
  write_dir 'write'
  public_key node['scponly']['public_key']
  chroot true
  not_if 'grep scponly_test_chroot /etc/passwd'
end

file '/var/lib/chroots/home/scponly_test_chroot/.ssh/id_rsa-scponly_user-scponly_test_chroot' do
  mode '0400'
  owner 'scponly_test_chroot'
  group 'scponly_test_chroot'
  content node['scponly']['private_key']
  sensitive true
end

execute 'fallocate -l 10m /tmp/testfile.img' do
  creates '/tmp/testfile.img'
end

file '/tmp/testfile.img' do
  owner 'scponly_test_chroot'
  group 'scponly_test_chroot'
end
