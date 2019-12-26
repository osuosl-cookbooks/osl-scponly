scponly_user 'scponly_test' do
  write_dir 'write'
  public_key node['scponly']['public_key']
  private_key node['scponly']['private_key']
  chroot false
end

execute 'fallocate -l 10m /tmp/testfile.img' do
  creates '/tmp/testfile.img'
end

file '/tmp/testfile.img' do
  owner 'scponly_test'
  group 'scponly_test'
end
