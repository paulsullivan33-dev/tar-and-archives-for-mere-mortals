# Compression, Compared Honestly

**Scope:** gzip, bzip2, xz, and zstd over the *same*
corpus, measured. These are this-corpus numbers on this
machine — a different mix of files will move them, and
the chapter says which direction and why.

## The measurement

The corpus is 2,233,717 bytes of files: very
compressible generated logs, small text notes, and one
256 KB file of random bytes that no compressor can
shrink. One run each, wall-clock timed:

```console
plain: 15 ms
gzip: 37 ms
bzip2: 591 ms
xz: 488 ms
zstd: 15 ms

$ ls -l out/corpus.tar.plain out/corpus.tar.gzip out/corpus.tar.bzip2 out/corpus.tar.xz out/corpus.tar.zstd
-rw-rw---- 1 root nogroup 2293760 … out/corpus.tar.plain
-rw-rw---- 1 root nogroup  378199 … out/corpus.tar.gzip
-rw-rw---- 1 root nogroup  299947 … out/corpus.tar.bzip2
-rw-rw---- 1 root nogroup  285128 … out/corpus.tar.zstd
-rw-rw---- 1 root nogroup  279312 … out/corpus.tar.xz
```

| Compressor | tar flag | Size | vs. plain | This run |
|---|---|---:|---:|---:|
| (none) | — | 2,293,760 | 100% | 15 ms |
| gzip | `-z` | 378,199 | 16% | 37 ms |
| bzip2 | `-j` | 299,947 | 13% | 591 ms |
| zstd | `--zstd` | 285,128 | 12% | 15 ms |
| xz | `-J` | 279,312 | 12% | 488 ms |

## How to read it

- **Everything decent lands within a few points of
  everything else.** On this corpus the whole field sits
  between 12% and 16%. The plain tar is *larger* than
  the files alone — tar pads members to 512-byte blocks
  and adds headers; on many-small-files trees that
  overhead is real.
- **The random file floors the ratio.** 262,144 of the
  corpus's bytes are incompressible noise, so even a
  perfect compressor can't go below ~11%. A corpus of
  pure logs would show far wider gaps; a corpus of
  already-compressed media (JPEGs, MP3s, other archives)
  would show almost none. Measure on *your* files before
  believing any table, including this one.
- **Speed is the real spread.** xz won on size and took
  ~13× gzip's time to do it; zstd matched xz's size at
  plain-tar speed *in this run*. bzip2 was slowest here
  and still bigger than xz/zstd — on modern machines it
  is mostly kept for compatibility with old archives.
- **Defaults were used throughout.** Each tool has level
  flags (`gzip -9`, `xz -9`, `zstd -19`) that trade more
  time for a little less size; chapter 6 shows the gzip
  version of that trade measured.

The mortal's summary: **gzip when anything anywhere
might need to read it, zstd or xz when the archive is
yours end-to-end, and whichever you pick, the difference
is smaller than the difference between compressing and
not.**

## Reading needs no flag

```console
$ tar -tf out/corpus.tar.xz | head -3
corpus/
corpus/notes/
corpus/notes/note-01.txt
```

No `-J`, no hint: on the way *in*, GNU tar detects the
compression format from the file's first bytes. The
flags are only for creating. (The matching error when
the hint is wrong is captured in chapter 13: a plain tar
fed to `tar -tzf` dies in gzip before tar sees a byte.)

**Check:** compress your own most-archived folder with
gzip and with xz and compare sizes. If they're within a
few percent — the common case — you've learned the
chapter in one command.
