NSS altfiles module
===================

This is a NSS module which can read user information from files
in the same format as `/etc/passwd` and `/etc/group` stored in an
alternate location (`/lib` by default).

Essentially, it is a tweaked copy of the sources for the NSS
`files` module included with [eglibc](http://eglibc.org). It
should work with [glibc2](http://www.gnu.org/software/libc/)
as well.

Usage
-----

List the module the `/etc/nsswitch.conf` configuration file.
For example:

    passwd: files altfiles
    group:  files altfiles

    # Other entries follow...

This will try to read files from `/etc` first, and under
`/lib` (using the `altfiles` module). Modifications will be
stored in the files under `/etc` (e.g. when using `passwd`
to change an user passwords).

Building
--------

The usual `./configure && make && make install` dance will
work. The `configure` script allows to change the install
path and the path to the alternative data files:

    ./configure --prefix=/installdir/path --datadir=/var

The example above would build an `altfiles` NSS module that
will read user information from `/var/passwd` and `/var/group`,
which is to be installed under `/installdir/path/lib`.

To ease the task of packagers, the `DESTDIR` variable can
be passed to `make`:

    make install DESTDIR=/tmp/fakerootdir

Version scheme
--------------

Version numbers follow the numbering of the eglibc releases,
adding a local revision number: `<eglibc version>.<revision>`.
For example version `2.13.0` would contain the source files
from eglibc 2.13, and the base modifications to make it the
`altfiles` module; version `2.15.3` would contain the source
files from eglibc 2.15, and the base modifications plus three
patches.

Git tags do also follow this versioning.

Licensing
---------

As eglibc is distributed under the terms of the LGPL 2.1, the
same applies to the extra bits needed to make `nss_altfiles`
work.

See the COPYING file in the source directory for the full
text of the license.

