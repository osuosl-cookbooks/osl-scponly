#
# Cookbook:: osl-scponly
# Recipe:: default
#
# Copyright:: 2019, Oregon State University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

%w(wget gcc man rsync openssh-clients).each do |p|
  package p
end

src_path = "#{node['scponly']['dir']}#{node['scponly']['srcfilename']}.tgz"
extract_path = "#{node['scponly']['dir']}#{node['scponly']['srcfilename']}"
install_path = '/usr/local/bin/scponly'

remote_file src_path do
  source node['scponly']['src']
  not_if { ::File.exist?(src_path) }
end

bash 'extract scponly' do
  user 'root'
  cwd node['scponly']['dir']
  code "tar -zxvf #{node['scponly']['srcfilename']}.tgz"
  not_if { ::File.exist?(extract_path) }
end

bash 'build and install scponly' do
  user 'root'
  cwd "#{node['scponly']['dir']}#{node['scponly']['srcfilename']}"
  code <<-EOH
    ./configure #{node['scponly']['config']}
    make
    make install
  EOH
  not_if { ::File.exist?(install_path) }
end

%w(/usr/local/bin/scponly /usr/local/sbin/scponlyc).each do |l|
  append_if_no_line "Append #{l} shell" do
    path '/etc/shells'
    line l
  end
end

group 'scponly'

directory node['scponly']['uploaddir'] do
  owner 'root'
  group 'scponly'
  mode '0770'
  recursive true
end

# TODO: testing, will remove once custom resource is hashed out
node['scponly']['users'].each do |u|
  user u do
    gid 'scponly'
    home "/home/#{u}"
    manage_home true
    shell '/usr/local/bin/scponlyc'
  end
  group u do
    members u
  end
  directory "/home/#{u}" do
    mode '0500'
  end
  directory "/home/#{u}/.ssh" do
    mode '0500'
    owner u
    group u
  end
  file "/home/#{u}/.ssh/authorized_keys" do
    mode '0400'
    owner u
    group u
  end
end
