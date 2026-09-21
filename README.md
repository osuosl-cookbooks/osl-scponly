# osl-scponly

Installs scponly and provides the `scponly_user` resource for creating
file-transfer-only accounts, either chrooted into a shared jail or confined only
by the shell.

scponly is a restricted shell: an account using it can run `scp` and `sftp` and
nothing else. It is how we hand out write access to a directory without handing
out a login.

## Requirements

### Platforms

- AlmaLinux 8
- AlmaLinux 9
- AlmaLinux 10

The `scponly` package comes from EPEL on AlmaLinux 8 and from the OSUOSL repo on
AlmaLinux 9 and 10 — EPEL stopped shipping it after EL8. `osl-scponly::default`
enables both repos, so which one supplies it is transparent to callers.

### Cookbooks

- line
- osl-repos
- yum-osuosl

`metadata.rb` also declares `osl-selinux`, but nothing in the cookbook itself uses
it; the only consumer is the test fixture, which labels the private key it drops
inside the jail.

## Attributes

None; everything is driven through resource properties.

## Resources

### scponly_user

Creates a transfer-only account: a user whose shell is one of the scponly
binaries, a matching primary group, a `.ssh/authorized_keys` holding
`public_key`, and one group-writable directory to drop files into. The resource
name is both the username and the name of its primary group.

The user is also appended to the shared `scponly` group, which owns every drop
directory. `osl-scponly::default` is included automatically, so a caller only
needs `depends 'osl-scponly'`.

```ruby
# Chrooted (the default): the account cannot see outside the jail.
scponly_user 'projectfoo' do
  public_key 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA... foo@example.org'
  write_dir 'incoming'
end

# Not chrooted: confined only by the scponly shell.
scponly_user 'projectbar' do
  public_key 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA... bar@example.org'
  chroot false
end
```

Actions: `:create` (default).

| Property | Type | Default | Description |
|---|---|---|---|
| `write_dir` | String | `'incoming'` | Name of the writable directory created under the account's home, owned `root:scponly` mode `0770`. The home itself is `0550`, so this is the only place the account can write. |
| `public_key` | String | *none* | Contents of the account's `.ssh/authorized_keys`. |
| `chroot` | true, false | `true` | `true` gives the account the `/usr/sbin/scponlyc` shell and a home inside `altroot`; `false` gives it `/usr/bin/scponly` and an ordinary `/home/<name>`. |
| `altroot` | String | `'/var/lib/chroots'` | The shared chroot jail. Ignored when `chroot` is `false`. |
| `binaries` | Array | see below | Binaries copied into the jail, along with the libraries `ldd` reports for each. Ignored when `chroot` is `false`. |

Default `binaries`: `/bin/chgrp`, `/bin/chmod`, `/bin/chown`, `/bin/ln`,
`/bin/ls`, `/bin/mkdir`, `/bin/mv`, `/bin/rm`, `/bin/rmdir`, `/bin/scp`,
`/usr/libexec/openssh/sftp-server`, `/usr/sbin/scponlyc`.

#### The jail is built once

Every chrooted account on a node shares one `altroot`. The jail is populated by
`/usr/libexec/scponly-chroot.sh`, run through an `execute` guarded with
`creates "#{altroot}/bin"` — so **on a node whose jail already exists, changing
`binaries` has no effect**. To add a binary to an existing jail, either run the
script by hand:

```console
# /usr/libexec/scponly-chroot.sh /var/lib/chroots /usr/bin/newthing
```

or remove `#{altroot}/bin` and converge to rebuild the whole jail.

The jail also receives copies of the host's `/etc/ld.so.cache`,
`/etc/ld.so.conf` and `/etc/group`, refreshed on every converge.

Its `/etc/passwd` is written the same `creates`-guarded way, and because the
command redirects rather than appends, **the jail's `/etc/passwd` ends up holding
only the first chrooted account converged on that node**. A second
`scponly_user` with `chroot true` will have a working jail but no passwd entry
inside it. Until that is fixed, append the line by hand when a node needs more
than one chrooted account.

## Recipes

- `default` — enables the EPEL and OSUOSL repos, installs `scponly`, registers
  both scponly binaries in `/etc/shells`, creates the shared `scponly` system
  group, and installs the jail-building script. It also asserts mode `4755` on
  `/usr/sbin/scponlyc`: `scponlyc` has to be setuid root to call `chroot(2)`,
  though the EL9 and EL10 packages already ship it that way. Included
  automatically by `scponly_user`, so a wrapper cookbook rarely calls it
  directly.

## Testing

`kitchen.yml` runs three suites on AlmaLinux 8, 9 and 10:

| Suite | Covers |
|---|---|
| `default` | the `default` recipe on its own — package, `/etc/shells` entries, the `scponly` group |
| `scponly` | a non-chrooted account, end to end |
| `scponly-chroot` | the same round trip for a chrooted account, plus the jail's contents and its `/etc/passwd` |

Both account suites share the round trip in
`test/integration/helpers/inspec/helpers_spec.rb`, which is the part that proves
the account actually works rather than merely exists: it scps a 10 MB file into
the drop directory, authenticating as that account with that account's own key,
and compares it byte for byte against the original. The same profile asserts the
modes that confine the account — `0550` on the home, `0770` `root:scponly` on the
drop directory.

## Contributing

1. Fork the repository on GitHub
1. Create a named feature branch (like `username/add_component_x`)
1. Write tests for your change
1. Write your change
1. Run the tests, ensuring they all pass
1. Submit a pull request on GitHub

## License and Authors

- Author:: Oregon State University <chef@osuosl.org>

```text
Copyright:: 2019-2026, Oregon State University

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
