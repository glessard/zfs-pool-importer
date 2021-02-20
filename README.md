# zfs-pool-importer

An improved tool to automatically import ZFS pools after macOS starts up.

The advantages over the shell script are that this command shows up by itself in the list of programs that have requested full disk access, and that `/bin/bash` isn't required to have full disk access.

What's required for `zfs-pool-importer` to request full disk access to happen is that it must be launched once; the operation that requires full disk access will fail, and `zfs-pool-importer` will appear in the list at "System Preferences -> Security & Privacy -> Full Disk Access", unchecked. The user can then choose to enable it.

There is no real difference in functionality compared to the shell script, though the log output is slightly different.
