scponly_user 'scponly_test_chroot' do
  write_dir 'write'
  public_key node['scponly']['public_key']
  private_key node['scponly']['private_key']
  chroot true
end

execute 'fallocate -l 10m /tmp/testfilec.img' do
  creates '/tmp/testfile.img'
end

file '/tmp/testfile.img' do
  owner 'scponly_test_chroot'
  group 'scponly_test_chroot'
end
