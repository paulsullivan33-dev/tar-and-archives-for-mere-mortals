# Troubleshooting

**Scope:** symptom → cause → fix, every error below a
real one from the lab (or, where marked, from extraction
behaviour the earlier chapters established).

## Files landed everywhere / overwrote things in place

**Cause:** the archive had no top folder — a tar bomb
(chapter 4) — and was extracted in a populated
directory.
**Fix:** none retroactive beyond picking up the pieces;
the prevention is the chapter-4 pair: list first, extract
into a fresh empty directory. For your own archives,
always archive a named folder, never `.`.

## `tar: <file>: file changed as we read it` — exit 1

```console
$ tar -cf out/changed.tar changed; echo "exit: $?"
tar: changed/growing.log: file changed as we read it
exit: 1
```

**Cause:** the file changed size while tar was reading
it — here, a log with a writer still appending. The
archive exists, but that member is a snapshot with a
tear in it (part old size, declared new size).
**Fix:** archive quiet files: stop or pause the writer,
or take the archive from a filesystem snapshot. For live
logs, accept the warning consciously — and never let a
backup script treat exit 1 as success. Scripts should
check tar's exit code; that warning is exactly what it's
for.

## `gzip: stdin: unexpected end of file` / `tar: Unexpected EOF in archive`

```console
$ tar -tzf out/truncated.tar.gz >/dev/null; echo "exit: $?"
gzip: stdin: unexpected end of file
tar: Unexpected EOF in archive
tar: Error is not recoverable: exiting now
exit: 2
```

**Cause:** the archive is truncated — download cut
short, copy interrupted, disk filled mid-write. The lab
specimen was the first 100,000 bytes of a 378,199-byte
file.
**Fix:** re-fetch or re-copy the file. If a checksum was
published, chapter 8 finds this before tar does. There
is no repair; a partial archive's intact prefix can be
listed (`tar -tzf` shows members until the tear) but
nothing past it exists.

## `tar: This does not look like a tar archive`

```console
$ tar -tf out/corpus.zip
tar: This does not look like a tar archive
tar: Skipping to next header
tar: Exiting with failure status due to previous errors
exit: 2
```

**Cause:** it isn't one — here, a zip file fed to tar.
Also seen for zero-length and overwritten files.
**Fix:** identify before opening: `file mystery.bin`
names most formats honestly. Then use the matching
tool (`unzip -l` for zip).

## `gzip: stdin: not in gzip format` / `tar: Child returned status 1`

```console
$ tar -tzf out/corpus.tar
gzip: stdin: not in gzip format
tar: Child returned status 1
exit: 2
```

**Cause:** the compression flag doesn't match the file —
a *plain* tar was fed to `tar -z`. The compressor dies
first, and tar reports its child's failure.
**Fix:** drop the flag. On reading, plain `tar -tf`
detects the format itself (chapter 5); creation is the
only side that needs the right letter.

## Every member: `Cannot change ownership … Operation not permitted`

**Cause:** tar — running as root, or with `--same-owner`
— tried to restore archived owners and the system said
no. On ordinary machines as a normal user this doesn't
appear (ownership is simply skipped, chapter 9); as root
it appears when the filesystem or kernel refuses `chown`
— this guide's build sandbox refuses it for everyone,
which is how it got captured so thoroughly.
**Fix:** extract with `--no-same-owner` when you don't
need the archived owners (most of the time, you don't),
and read chapter 9 before deciding you do.

## A zip twice the size it should be, full of duplicates

**Cause:** `zip -r` followed symlinks and archived the
targets' trees under the links' names (chapter 7: forty
notes, twice).
**Fix:** rebuild with `zip -ry` to store links as links,
and confirm with `unzip -l` before sending.

## The archive is enormous and mostly one file

**Cause:** a sparse file archived without `--sparse`
(chapter 12: 10,240 vs 1,054,720 bytes for the same
specimen).
**Fix:** recreate with `--sparse`. Nothing recovers the
space from the fat archive except rebuilding it.

## The archive barely shrinks, whichever compressor you pick

**Cause:** the content genuinely doesn't compress —
already-compressed media, encrypted data, random bytes.
Chapter 5's corpus has one such file on purpose.
**Fix:** none, and that's the lesson: check with
`gzip -l` or a trial run before blaming the tool.

**Check:** deliberately truncate a copy of an archive
(`head -c 100000 good.tar.gz > bad.tar.gz`) and meet the
EOF error here, in the lab, so it's a familiar face when
a download dies somewhere real.
