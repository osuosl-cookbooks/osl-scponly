scponly_user 'scponly_test' do
  write_dir 'write'
  public_key node['scponly']['public_key']
  chroot false
end

file '/home/scponly_test/.ssh/id_rsa-scponly_user-scponly_test' do
  mode '0400'
  owner 'scponly_test'
  group 'scponly_test'
  content node['scponly']['private_key']
  sensitive true
end

execute 'fallocate -l 10m /tmp/testfile.img' do
  creates '/tmp/testfile.img'
end

file '/tmp/testfile.img' do
  owner 'scponly_test'
  group 'scponly_test'
end
