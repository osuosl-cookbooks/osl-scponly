# To learn more about Custom Resources, see https://docs.chef.io/custom_resources.html

resource_name :scponlyc_user

default_action :create

property :pub_dir, String, default: '/pub'
property :public_key, String
property :private_key, String

action :create do
  run_context.include_recipe 'osl-scponly::default'

  directory new_resource.pub_dir do
    owner 'root'
    group 'scponly'
    mode '0770'
    recursive true
  end

  user new_resource.name do
    gid 'scponly'
    home "/home/#{new_resource.name}"
    manage_home true
    shell '/usr/sbin/scponlyc'
  end

  group new_resource.name do
    members new_resource.name
  end

  directory "/home/#{new_resource.name}" do
    mode '0500'
  end

  directory "/home/#{new_resource.name}/.ssh" do
    mode '0500'
    owner new_resource.name
    group new_resource.name
  end

  file "/home/#{new_resource.name}/.ssh/authorized_keys" do
    content new_resource.public_key
    mode '0400'
    owner new_resource.name
    group new_resource.name
  end

  cookbook_file "/home/#{new_resource.name}/.ssh/#{new_resource.private_key}" do
    mode '0400'
    owner new_resource.name
    group new_resource.name
    source new_resource.private_key
  end
end
