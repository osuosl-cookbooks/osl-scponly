osl-scponly Cookbook
====================
Installs scponly and provides resources to create chrooted and non-chrooted scponly users

Requirements
============

Platform
--------
* Centos 7


#### packages
- `scponly` - osl-scponly needs scponly create scponly users

Usage
-----
#### osl-scponly::default

Add osl-scponly dependency to your cookbook and utilize `scponly_user` resource as follows:

```ruby
scponly_user 'scponly_test' do
  write_dir 'write_dir'
  public_key 'public_key'
  chroot false
end

# to create a chrooted user
scponly_user 'scponly_test_chroot' do
  write_dir 'write_dir'
  public_key 'public_key'
  chroot true
  altroot path_to_chroot
end
```

Contributing
------------

1. Fork the repository on Github
2. Create a named feature branch (like `username/add_component_x`)
3. Write tests for your change
4. Write your change
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
- Author:: Oregon State University <chef@osuosl.org>

```text
Copyright:: 2019, Oregon State University

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
