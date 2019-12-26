#true To learn more about Custom Resources, see https://docs.chef.io/custom_resources.html

resource_name :scponly_user

default_action :create

property :write_dir, String, default: 'incoming'
property :public_key, String
property :private_key, String
property :chroot, [true, false], default: true

action :create do
  run_context.include_recipe 'osl-scponly::default'

  if new_resource.chroot
    directory '/home/chroot' do
    end

    user new_resource.name do
      gid 'scponly'
      home "/home/chroot//#{new_resource.name}"
      manage_home true
      shell '/usr/sbin/scponlyc'
    end

    altroot = "/home/chroot//#{new_resource.name}"
    %w(chgrp chmod chown ln ls mkdir mv rm rmdir scp).each do |bin|
      bash "Chroot #{bin}" do
        code <<-EOH
          altroot="#{altroot}"
          binary=$(which #{bin})
          d=$(dirname ${binary})
          if [ ! -d "${altroot}/${d}" ]; then
            /bin/mkdir -p "${altroot}${d}"
          fi
          /bin/cp ${binary} "${altroot}${d}"

          LIBS=$(ldd ${binary} | awk '{ print $3 }')

          for i in ${LIBS}; do
            d=$(dirname ${i})
            if [ ! -d "${altroot}${d}" ]; then
              /bin/mkdir -p "${altroot}${d}"
            fi
            /bin/cp "${i}" "${altroot}${d}"
          done

          ld="$(ldd "${binary}" | grep 'ld-linux' | awk '{ print $1 }')"
          d="$(dirname "${ld}")"

          if [ ! -d "${altroot}${d}" ]; then
            /bin/mkdir -p "${altroot}${d}"
          fi
          bin/cp "${ld}" "${altroot}${d}"

        EOH
      end
    end

    bash "Chroot /usr/sbin/scponlyc" do
      code <<-EOH
        altroot="#{altroot}"
        binary=/usr/sbin/scponlyc
        d=$(dirname ${binary})
        if [ ! -d "${altroot}/${d}" ]; then
          /bin/mkdir -p "${altroot}${d}"
        fi
        /bin/cp ${binary} "${altroot}${d}"

        LIBS=$(ldd ${binary} | awk '{ print $3 }')

        for i in ${LIBS}; do
          d=$(dirname ${i})
          if [ ! -d "${altroot}${d}" ]; then
            /bin/mkdir -p "${altroot}${d}"
          fi
          /bin/cp "${i}" "${altroot}${d}"
        done
      EOH
    end

    directory "#{altroot}/etc"
    %w(ld.so.cache ld.so.conf group).each do |c|
      bash "Chroot /etc/#{c}" do
        code "cp /etc/#{c} #{altroot}/etc/"
      end
    end

    bash 'Chroot /etc/passwd' do
      code "cat /etc/passwd | grep #{new_resource.name} > #{altroot}/etc/passwd"
    end

    replace_or_add "Modify chroot /etc/passwd"do
      path "#{altroot}/etc/passwd"
      pattern /home.*/
      line "#{altroot}//home/#{new_resource.name}:/usr/sbin/scponlyc"
    end

  else
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

  directory "/home/#{new_resource.name}" do
    mode '0550'
  end

  directory "/home/#{new_resource.name}/.ssh" do
    mode '0550'
    owner new_resource.name
    group new_resource.name
  end

  file "/home/#{new_resource.name}/.ssh/authorized_keys" do
    content new_resource.public_key
    mode '0400'
    owner new_resource.name
    group new_resource.name
  end

  file "/home/#{new_resource.name}/.ssh/id_rsa-scponly_user-#{new_resource.name}" do
    mode '0400'
    owner new_resource.name
    group new_resource.name
    content new_resource.private_key
    sensitive true
  end
end
