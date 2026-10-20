# Glossary

**Archive** — one file that carries many files: their
names, tree structure, modes, timestamps, and contents.

**Archiving** — job one: packing a tree into one file.
Done by tar (and by zip, in its own format).

**Checksum (fingerprint)** — a short value computed from
a file's bytes, e.g. a SHA-256 hex string. Identical
files share it; a one-byte change destroys the match.

**Compression** — job two: encoding a byte stream
smaller by exploiting repetition. Done by gzip, bzip2,
xz, zstd — and inside zip, per member.

**Corpus** — a body of files used for a measurement.
Every number in chapter 5 is a property of *its* corpus,
not of the tools in general.

**Extract** — unpacking an archive back into files
(tar's `x` mode). The moment an archive's stored paths,
modes, and owners meet a real filesystem.

**Hard link** — a second (or third) name for the same
file: one inode, one set of bytes, several directory
entries.

**Member** — one entry inside an archive: a file, a
directory, a link, each stored with its own header.

**Mode** — a file's permission bits (read/write/execute
for owner/group/other, plus setuid/setgid/sticky),
shown by `ls -l` and `tar -tvf` as `-rw-r--r--` and kin.

**pax** — the modern tar header format (extended
headers) that carries long names and fine-grained
timestamps past the old format's limits.

**Round trip** — archive → extract elsewhere → compare.
The smallest honest proof that an archive is good.

**Setuid bit** — a mode bit (`s` in the execute slot)
making a program run with its owner's privileges. The
bit chapter 9 watches most carefully.

**Sparse file** — a file whose empty regions are stored
as holes rather than as real zero bytes: big to `ls`,
small to `du`, and fat in an archive made without
`--sparse`.

**Stream** — an archive that never becomes a file:
written by one tar to stdout, read by another from
stdin, through a pipe or an ssh connection.

**Tar bomb** — an archive with no top-level folder,
whose members scatter into whatever directory it's
extracted in. Rude, occasionally dangerous, always
visible in the listing first.

**Tarball** — the everyday word for a tar archive,
usually a compressed one (`.tar.gz`).

**Umask** — the mask of permission bits a process's new
files *lose* by default; extraction without `-p` passes
archived modes through the extractor's umask.
