# true To learn more about Custom Resources, see https://docs.chef.io/custom_resources.html

resource_name :scponly_user

default_action :create

property :write_dir, String, default: 'incoming'
property :public_key, String
property :private_key, String
property :chroot, [true, false], default: true
property :altroot, String
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
            /usr/sbin/scponlyc
          )

action :create do
  run_context.include_recipe 'osl-scponly::default'

  group new_resource.name

  if new_resource.chroot

    altroot = new_resource.altroot.nil? ? '/home/chroot' : new_resource.altroot

    directory "#{altroot}/home" do
      group 'scponly'
      recursive true
    end

    user new_resource.name do
      gid new_resource.name
      manage_home true
      home "#{altroot}//home/#{new_resource.name}"
      shell '/usr/sbin/scponlyc'
    end

    directory "#{altroot}/home/#{new_resource.name}/#{new_resource.write_dir}" do
      owner 'root'
      group 'scponly'
      mode '0770'
      recursive true
    end

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

    execute "grep #{new_resource.name} /etc/passwd > #{altroot}/etc/passwd" do
      creates "#{altroot}/etc/passwd"
    end

    filter_lines "#{altroot}/etc/passwd/" do
      filters(substitute: [%r{/home/chroot}, %r{/home/chroot}, ''])
      sensitive false
    end

  else
    altroot = ''
    user new_resource.name do
      gid new_resource.name
      home "/home/#{new_resource.name}"
      manage_home true
      shell '/usr/bin/scponly'
    end
    directory "/home/#{new_resource.name}/#{new_resource.write_dir}" do
      owner 'root'
      group 'scponly'
      mode '0770'
      recursive true
    end
  end

  group 'scponly' do
    members new_resource.name
  end

  directory "#{altroot}/home/#{new_resource.name}" do
    mode '0550'
    owner 'root'
    group new_resource.name
  end

  directory "#{altroot}/home/#{new_resource.name}/.ssh" do
    mode '0550'
    owner new_resource.name
    group new_resource.name
  end

  file "#{altroot}/home/#{new_resource.name}/.ssh/authorized_keys" do
    content new_resource.public_key
    mode '0400'
    owner new_resource.name
    group new_resource.name
  end

  file "#{altroot}/home/#{new_resource.name}/.ssh/id_rsa-scponly_user-#{new_resource.name}" do
    mode '0400'
    owner new_resource.name
    group new_resource.name
    content new_resource.private_key
    sensitive true
  end
end