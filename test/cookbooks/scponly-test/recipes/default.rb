scponlyc_user 'testuser' do
  pub_dir '/pub/upload'
  public_key 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDdGxkN6/NsJMnVNFPHm0mcNRk3y+UQfwOAqC6TM/fcMgkn4ptLjoloPgCmgF01cKGLSpGrFLtBV2LFKDgSvGpTvEzikW1vzgKyplwcSs6ZVYsraJ3wvAsKdyKFXjRJ4dDeWumvR1BhsmvcPABUOKXBQsaXor448hXwef/N/RRnP9rRORpxOdKcOvCgR1bwEdqZwum5ynWOS7agaXI2ToBLUV4Sygx9PeOB/lPHYiuMDtZEyWQgZX0xqvsAxjwM5mNAZoUVIm1zUBH7R/TpZieygF4QBfuKDI9+XmOFrdufti0jzQov1cIY1ptdpFnp84tWKsjLfDTR7/o5bNpUW0AZ centos@defaultcentos7-vancelot-oliveworkstationcassore-702zjsl.novaloca'
  private_key 'id_rsa'
end

execute 'fallocate -l 10m /tmp/testfile.img' do
  creates '/tmp/testfile.img'
end

file '/tmp/testfile.img' do
  owner 'testuser'
  group 'testuser'
end
