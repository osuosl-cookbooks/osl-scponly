default['scponly']['dir'] = '/opt/'
default['scponly']['srcfilename'] = 'scponly-20110526'
default['scponly']['src'] = "http://sourceforge.net/projects/scponly/files/scponly-snapshots/#{node['scponly']['srcfilename']}.tgz"
default['scponly']['compats'] = %w(
  --enable-chrooted-binary
  --enable-winscp-compat
  --enable-rsync-compat
  --enable-scp-compat
)
default['scponly']['sftpserver'] = '/usr/libexec/openssh/sftp-server'
default['scponly']['config'] = "#{node['scponly']['compats'].join(' ')} --with-sftp-server=#{node['scponly']['sftpserver']}"

default['scponly']['uploaddir'] = '/pub/upload'
default['scponly']['users'] = %w(testuser)
