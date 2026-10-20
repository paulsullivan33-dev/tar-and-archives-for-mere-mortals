# Tar's Grammar

**Scope:** the handful of letters everything else is
built from, and how to read a listing like a table.

## One mode letter, then the details

Every tar command picks exactly one **mode**:

| Letter | Mode | Meaning |
|---|---|---|
| `c` | create | build a new archive from files |
| `x` | extract | unpack an archive into files |
| `t` | list | print what's inside, change nothing |
| `r` | append | add files to the end of an existing (uncompressed) archive |
| `u` | update | append only files newer than their archived copies |

Then the supporting letters:

| Letter | Meaning |
|---|---|
| `f` | the archive is a **file**, and its name comes next — without `f`, tar aims at a tape drive or a pipe |
| `v` | verbose: name each file as it's processed |
| `z` / `j` / `J` / `--zstd` | route the stream through gzip / bzip2 / xz / zstd |
| `C` | change directory before starting |
| `p` | preserve permissions exactly (chapter 9) |

```console
$ tar -cvf out/corpus.tar corpus
corpus/
corpus/notes/
corpus/notes/note-01.txt
...
```

Read it as: **c**reate, **v**erbose, **f**ile
`out/corpus.tar`, from the tree `corpus`.

The letter-bundle style is historical, and it shows: the
first argument may be given *without* a dash at all —
`tar cvf out.tar dir` is the same command, a spelling
older manuals use and old scripts still carry. Modern
long options (`--create --verbose --file`) exist for
every letter and are kinder in scripts; the letters are
what you'll meet in the wild, so this guide uses them.

## The lab corpus

Every chapter works on one fixture tree, built by the
script shipped in `examples/` so you can rebuild it
exactly:

```console
$ sh examples/make-corpus.sh corpus
corpus built in corpus
```

It mixes the shapes archives actually meet: forty small
text notes, three ~650 KB generated logs, one 256 KB
file of random bytes, an executable script, a private
file (mode 600), an empty directory, a symlink, and three
scratch `.tmp` files to have something worth excluding.

## Reading a listing as a table

`t` is the safe mode — it changes nothing — and `-v`
turns its output into the same table `ls -l` readers
already know:

```console
$ tar -tvf out/corpus.tar | grep -E "note-07|app-1.log|random.bin|secret.txt|run.sh|latest|empty-dir"
-rw-rw---- root/nogroup     77 2026-10-20 22:24 corpus/notes/note-07.txt
-rw-rw---- root/nogroup 656071 2026-10-20 22:24 corpus/logs/app-1.log
-rw-rw---- root/nogroup 262144 2026-10-20 22:24 corpus/data/random.bin
-rwxr-xr-x root/nogroup     42 2026-10-20 22:24 corpus/bin/run.sh
drwxrws--- root/nogroup      0 2026-10-20 22:24 corpus/empty-dir/
-rw------- root/nogroup     52 2026-10-20 22:24 corpus/secret.txt
lrwxrwxrwx root/nogroup      0 2026-10-20 22:24 corpus/latest -> notes
```

Mode, owner, size, date, name — plus two things `ls`
can't tell you about a file you haven't extracted yet:
the symlink is stored *as a symlink* (`latest -> notes`,
never followed), and the empty directory is present as
a member in its own right. Keep both facts; chapters 7
and 12 lean on them.

**Check:** run `tar -tvf` on any archive you already
have and read three rows aloud — mode, owner, size,
name. If the symlink row shows an arrow rather than a
size, you've read it right.
