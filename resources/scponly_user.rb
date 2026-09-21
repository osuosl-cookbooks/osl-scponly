provides :scponly_user
unified_mode true

default_action :create

property :write_dir, String, default: 'incoming'
property :public_key, String
property :chroot, [true, false], default: true
property :altroot, String, default: '/var/lib/chroots'
property :binaries,
          Array,
          default:
          %w(
            /bin/chgrp
            /bin/chmod
            /bin/chown
            /bin/ln
            /bin/ls
            /bin/mkdir
            /bin/mv
            /bin/rm
            /bin/rmdir
            /bin/scp
            /usr/libexec/openssh/sftp-server
            /usr/sbin/scponlyc
          )

action :create do
  run_context.include_recipe 'osl-scponly::default'

  account = new_resource.name
  # Empty for a non-chrooted account, so every path below is written once.
  altroot = new_resource.chroot ? new_resource.altroot : ''
  home_dir = "#{altroot}/home/#{account}"
  # scponlyc splits the passwd home on '//' to find the chroot point: it chroots
  # to what precedes it and chdirs to what follows. Collapsing it chroots the
  # account into its own empty home, where none of the jail's binaries exist.
  passwd_home = new_resource.chroot ? "#{altroot}//home/#{account}" : home_dir

  group account

  if new_resource.chroot
    directory "#{altroot}/home" do
      group 'scponly'
      recursive true
    end
  end

  user account do
    gid account
    home passwd_home
    manage_home true
    shell new_resource.chroot ? '/usr/sbin/scponlyc' : '/usr/bin/scponly'
  end

  group "scponly append #{account}" do
    group_name 'scponly'
    append true
    members account
    action :modify
  end

  directory "#{home_dir}/#{new_resource.write_dir}" do
    owner 'root'
    group 'scponly'
    mode '0770'
    recursive true
  end

  if new_resource.chroot
    execute 'Build chroot jail' do
      command "/usr/libexec/scponly-chroot.sh #{altroot} #{new_resource.binaries.join(' ')}"
      creates "#{altroot}/bin"
    end

    directory "#{altroot}/etc"

    %w(ld.so.cache ld.so.conf group).each do |c|
      remote_file "#{altroot}/etc/#{c}" do
        source "file:///etc/#{c}"
      end
    end

    # One line per account: a redirect left all but the first account out.
    # Lazy because the helper reads what the user resource above just wrote.
    append_if_no_line "Add #{account} to #{altroot}/etc/passwd" do
      path "#{altroot}/etc/passwd"
      line lazy { osl_scponly_jail_passwd_line(altroot, account) }
      sensitive false
    end
  end

  directory home_dir do
    mode '0550'
    owner 'root'
    group account
  end

  directory "#{home_dir}/.ssh" do
    mode '0550'
    owner account
    group account
  end

  file "#{home_dir}/.ssh/authorized_keys" do
    content new_resource.public_key
    mode '0400'
    owner account
    group account
  end
end
