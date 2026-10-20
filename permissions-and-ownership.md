# Permissions and Ownership

**Scope:** what extraction does to modes and owners —
which depends on *who extracts*, a fact that surprises
everyone exactly once. The lab archive for this chapter
was built on purpose: a 644 note, a 600 private file, a
755 script, and a 4755 **setuid** binary (a copy of
`/bin/true` with the setuid bit set).

```console
$ tar -tvf out/perms.tar
drwxr-xr-x root/nogroup  0 … perm-src/
-rw-rw---- root/nogroup 14 … perm-src/sub/readme.txt
-rw-r--r-- root/nogroup 14 … perm-src/readme.txt
-rw------- root/nogroup 17 … perm-src/private.txt
-rwxr-xr-x root/nogroup 22 … perm-src/helper.sh
-rwsr-xr-x root/nogroup 26936 … perm-src/suid-tool
```

The `s` in `-rwsr-xr-x` is the setuid bit: a program
that runs with its *owner's* privileges, whoever runs
it. Keep your eye on that row.

## Extracted by a normal user, default flags

```console
$ runuser -u mortal -- tar -xf /home/mortal/lab/perms.tar -C /home/mortal/lab
$ ls -la /home/mortal/lab/perm-src
-rwxr-x--- 1 mortal mortal 22 … helper.sh
-rw------- 1 mortal mortal 17 … private.txt
-rw-r----- 1 mortal mortal 14 … readme.txt
-rwxr-x--- 1 mortal mortal 26936 … suid-tool
```

Three rules, all visible in the rows:

- **Ownership is not restored.** Everything belongs to
  `mortal`, the extractor. The archive's `root/nogroup`
  is ignored — a normal user cannot give files away to
  another account, so tar doesn't try.
- **Modes pass through the extractor's umask.** The
  lab's umask was 007, so `readme.txt` lost its
  other-read bit (644 → 640) and `helper.sh` its
  other-bits (755 → 750). Modes can only lose bits here,
  never gain.
- **The setuid bit is stripped outright.** `suid-tool`
  came back 750, plain. Whatever the archive claimed,
  a non-root extraction cannot mint a privileged binary.

## Extracted by a normal user with -p

`-p` (`--preserve-permissions`) says: restore the
archived modes exactly, umask be ignored.

```console
$ runuser -u mortal -- tar -xpf /home/mortal/lab/perms.tar -C /home/mortal/lab
$ ls -l /home/mortal/lab/perm-src/suid-tool /home/mortal/lab/perm-src/sub/readme.txt
-rw-rw---- 1 mortal mortal 14 … /home/mortal/lab/perm-src/sub/readme.txt
-rwsr-xr-x 1 mortal mortal 26936 … /home/mortal/lab/perm-src/suid-tool
```

The exact modes return — 660 where 660 was archived —
**and the setuid bit returns too**, now on a binary
owned by `mortal`. A setuid-*mortal* binary in mortal's
own directory harms no one. But read the same capture
with the extractor as root and it becomes the careful
lesson of this chapter:

## Extracted as root

Root extraction is the mirror image: tar assumes
`--same-owner` and `-p` **by default for root**. Owners,
modes, and special bits all come back as archived —
our root extraction restored `suid-tool` as
`-rwsr-xr-x`, a working setuid-root binary, created by
unpacking an archive. That is exactly right for
restoring a system from *your own* backup, and exactly
wrong to do casually with a stranger's tarball. (Chapter
10 builds the habits around it: list first, extract into
an empty directory, and don't be root for untrusted
archives at all.)

Root has two escape hatches for archives that aren't
system restores: `--no-same-owner` (take ownership
yourself) and dropping `-p` behaviour with
`--no-same-permissions`.

*Lab note:* this build machine's kernel refuses `chown()`
even for root, so the lab's root extractions print
`Cannot change ownership to uid 0, gid 65534: Operation
not permitted` and exit non-zero — while the modes land
exactly as shown. On an ordinary machine the ownership
change succeeds silently. The refusal is a property of
this sandbox, captured rather than smoothed over;
everything else in the tables is stock GNU tar 1.35
behaviour.

## Names are a local lookup

The `root/nogroup` in a listing is your machine looking
the archive's numbers up in *its* passwd file. The
archive really carries numbers:

```console
$ tar --numeric-owner -tvf out/perms.tar | head -3
drwxr-xr-x 0/65534  0 … perm-src/
drwxr-xr-x 0/65534  0 … perm-src/sub/
-rw-rw---- 0/65534 14 … perm-src/sub/readme.txt
```

Uid 0 is root nearly everywhere; uid 65534 is `nobody`'s
group here wearing a name your machine gave it. When an
archive crosses machines, restore operations that care
about owners work from these numbers — one more reason
system restores are a deliberate act, not a reflex.

**Check:** archive a folder containing a 600 file and a
755 script, extract it as a different user (or into a
scratch account), and predict every resulting mode
before you `ls`. Any row that surprises you is a row to
re-read above.
