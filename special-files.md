# Special Files: Sparse, Hard-Linked, and Otherwise Odd

**Scope:** the members that aren't plain files with
plain bytes — where an archive can quietly grow by a
gigabyte, or a link can arrive as a silent copy.

## Sparse files: mostly nothing, stored faithfully

A **sparse file** is mostly holes: regions that read as
zeros but occupy no disk. Virtual-disk images and
database files are often sparse. The lab's specimen is
10 real bytes in a 1 MiB frame:

```console
$ ls -l special/sparse.bin && du -h special/sparse.bin
-rw-rw---- 1 root nogroup 1048581 … special/sparse.bin
8.0K	special/sparse.bin
```

`ls` reports the logical size; `du` reports the 8 KB
actually stored. Archive it two ways:

```console
$ tar -cf out/sparse-naive.tar -C special sparse.bin
$ tar -cf out/sparse-aware.tar --sparse -C special sparse.bin
$ ls -l out/sparse-*.tar
-rw-rw---- 1 root nogroup   10240 … out/sparse-aware.tar
-rw-rw---- 1 root nogroup 1054720 … out/sparse-naive.tar
```

Without `--sparse`, tar reads the holes as real zeros
and the archive carries all 1,054,720 bytes of nothing.
With it, tar notes the holes as holes: 10,240 bytes. The
catch that decides whether to care: `--sparse` is a
*creation* flag. An archive made naively stays fat, and
extracting the aware archive restores the holes — which
`du` will confirm. If you archive VM images, this one
flag is the difference between a backup set and a disk
full of zeros.

## Hard links: two names, one file

A hard link is a second name for the same file — same
inode, same bytes, no copy. The lab pair:

```console
$ ls -li special/original.txt special/second-name.txt
7415033 -rw-rw---- 2 root nogroup 26 … special/original.txt
7415033 -rw-rw---- 2 root nogroup 26 … special/second-name.txt
```

Same inode number (first column), link count 2. Tar
understands the relationship and stores it *as* a
relationship:

```console
$ tar -tvf out/links.tar
-rw-rw---- root/nogroup 26 … original.txt
hrw-rw---- root/nogroup  0 … second-name.txt link to original.txt
```

The `h` type and `link to` in the listing: the second
member carries no bytes at all. Extraction (with
`--no-same-owner`, per chapter 9's sidebar) restores the
pair sharing one inode again — the link survives the
round trip. Contrast with chapter 7's zip, whose default
was to follow a *symlink* and copy the tree; tar stores
both link kinds as what they are, and its listings say
so.

## Named briefly

- **Symlinks** are stored as links, never followed, at
  create time — chapter 2's `latest -> notes` row.
  (Extraction-time links are chapter 10's subject.)
- **Device files and FIFOs** can be archived by root and
  are why "just extract it as root and see" is bad
  advice for stranger archives: a member can *be* a
  device node. They aren't created in this lab.
- **Very long names and odd characters** ride in an
  extended (pax) header in modern GNU tar; listings show
  them normally. Old, old tars had a 100-character wall —
  you'll meet it in documentation more often than in
  files.

**Check:** `du` and `ls -l` disagree about a file's size
on your system? Archive it with and without `--sparse`
and watch the two archives disagree the same way.
