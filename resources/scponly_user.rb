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
            /usr/bin/scp
            /usr/sbin/scponlyc
          )

action :create do
  run_context.include_recipe 'osl-scponly::default'

  if new_resource.chroot

    altroot = new_resource.altroot.nil? ? '/home/chroot' : new_resource.altroot

    directory "#{altroot}/home/#{new_resource.name}" do
      recursive true
    end

    user new_resource.name do
      gid 'scponly'
      manage_home true
      home "#{altroot}/home/#{new_resource.name}"
      shell '/usr/sbin/scponlyc'
    end

    directory "#{altroot}/home/#{new_resource.name}/#{new_resource.write_dir}" do
      owner 'root'
      group 'scponly'
      mode '0770'
      recursive true
    end

    directory '/usr/share/libexec/'
    cookbook_file '/usr/share/libexec/scponly-chroot.sh' do
      source 'scponly-chroot.sh'
      mode '0755'
    end

    execute 'Build chroot jail' do
      command "bash /usr/share/libexec/scponly-chroot.sh #{altroot} #{new_resource.binaries.join(' ')}"
      creates "#{altroot}/bin"
    end

    directory "#{altroot}/etc"
    %w(ld.so.cache ld.so.conf group).each do |c|
      remote_file "#{altroot}/etc/#{c}" do
        source "file:///etc/#{c}"
      end
    end

    bash 'Chroot /etc/passwd' do
      code "cat /etc/passwd | grep #{new_resource.name} > #{altroot}/etc/passwd"
    end

    replace_or_add 'Modify chroot /etc/passwd' do
      path "#{altroot}/etc/passwd"
      pattern /home.*/
      line "#{altroot}:/usr/sbin/scponlyc"
    end

  else
    altroot = ''
    user new_resource.name do
      gid 'scponly'
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

  group new_resource.name do
    members new_resource.name
  end

  directory "#{altroot}/home/#{new_resource.name}" do
    mode '0550'
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
