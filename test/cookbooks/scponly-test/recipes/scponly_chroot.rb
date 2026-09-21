include_recipe 'osl-selinux'

# Two accounts sharing one jail, because a single account never exercised the
# jail's passwd database being written once per account.
%w(scponly_test_chroot scponly_test_chroot2).each do |account|
  scponly_user account do
    write_dir 'write'
    public_key node['scponly']['public_key']
    chroot true
  end

  key = "/var/lib/chroots/home/#{account}/.ssh/id_rsa-scponly_user-#{account}"

  selinux_fcontext key do
    secontext 'ssh_home_t'
  end

  file key do
    mode '0400'
    owner account
    group account
    content node['scponly']['private_key']
    sensitive true
  end

  # One payload per account so each round trip asserts its own ownership.
  execute "fallocate -l 10m /tmp/testfile-#{account}.img" do
    creates "/tmp/testfile-#{account}.img"
  end

  file "/tmp/testfile-#{account}.img" do
    owner account
    group account
  end
end
