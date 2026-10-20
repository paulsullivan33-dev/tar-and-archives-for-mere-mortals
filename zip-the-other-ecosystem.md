# zip: The Other Ecosystem

**Scope:** the format the rest of the world sends you.
Zip does both jobs in one format — archiving and
per-file compression in a single container — and it is
the native archive of the Windows world, which is most
of why it exists on your machine at all.

## Same corpus, different shape

```console
$ zip -r out/corpus.zip corpus | tail -4
  adding: corpus/latest/note-40.txt (deflated 14%)
  adding: corpus/latest/draft-a.tmp (deflated 3%)
  ...
$ ls -l out/corpus.zip
-rw-rw---- 1 root nogroup 395718 … out/corpus.zip
```

Two things already differ from tar. Each file is
compressed **individually** ("deflated 14%"), so zip can
extract one member without decompressing everything
before it — and repetition *across* files earns nothing,
where the tar pipeline compresses the whole stream as
one. And look at the paths being added: `corpus/latest/…`
— a whole second copy of the notes. The corpus's
`latest` is a symlink to `notes/`, and **zip followed it
by default**, archiving the target's contents a second
time under the link's name:

```console
$ unzip -l out/corpus.zip | grep -c "corpus/latest/note"
40
```

All forty notes, twice. The fix is `-y`, which stores
the link *as* a link — five bytes, the target's name:

```console
$ zip -ry out/corpus-links.zip corpus >/dev/null && unzip -l out/corpus-links.zip | grep -E "latest|empty-dir|run.sh|secret"
       42 2026-10-20 22:24   corpus/bin/run.sh
        0 2026-10-20 22:24   corpus/empty-dir/
       52 2026-10-20 22:24   corpus/secret.txt
        5 2026-10-20 22:24   corpus/latest
$ mkdir zip-out && cd zip-out && unzip -q ../out/corpus-links.zip && ls -la corpus/ | grep -E "latest|empty"
drwxrwx--- 1 root root 0 … empty-dir
lrwxrwxrwx 1 root root 5 … latest -> notes
```

With `-y`, `unzip` restores a real symlink, and the
empty directory survives too. (*How* zip stores things
is a per-tool behaviour, not a format promise — other
zip writers differ, which is why the listing in
chapter 4 matters more than assumptions.)

## Listing and extracting

`unzip -l` is zip's `tar -tf`: names, sizes, dates, no
changes made. Plain `unzip file.zip` extracts into the
current directory; `unzip file.zip -d unpack` names the
target, and is the form to use — chapter 4's fresh-empty-
directory rule applies to zips exactly as to tarballs.

## What zip keeps, and what it doesn't

- **Kept:** names, the tree, timestamps, basic Unix
  modes (when a Unix tool wrote the zip and reads it
  back — the `-y` extraction above came back with its
  link). Zip files carry an attribute block per member;
  the Unix flavour of it is an Info-ZIP convention, not
  something every writer fills in.
- **Not kept:** ownership. Nothing in the zip you receive
  will restore files as another user; everything lands
  owned by whoever extracts it. Archives that must carry
  owners belong to tar (chapter 9).
- **Weaker by default on links**, as the capture shows:
  the naive `zip -r` doubles your symlinked trees.

And the rule that decides most real encounters: **send
zip to people on Windows, tar.gz to people on Unix** —
each opens natively on the other side of that line, and
struggling with the wrong one is a cost you can simply
not impose.

**Check:** list a zip you were sent (`unzip -l`) and
count its top folders. Then check for members stored
twice under a symlinked name — more common in the wild
than you'd hope.
