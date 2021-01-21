#
# Cookbook:: osl-scponly
# Recipe:: default
#
# Copyright:: 2019-2021, Oregon State University
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

include_recipe 'osl-repos::epel'

package 'scponly'

file '/usr/sbin/scponlyc' do
  mode '4755'
end

%w(
  /usr/bin/scponly
  /usr/sbin/scponlyc
).each do |s|
  append_if_no_line "Add #{s} shell" do
    path '/etc/shells'
    line s
  end
end

group 'scponly' do
  system true
  append true
end

cookbook_file '/usr/libexec/scponly-chroot.sh' do
  source 'scponly-chroot.sh'
  mode '0755'
end
