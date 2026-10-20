# Tar & Archives for Mere Mortals

Every backup, release, and log bundle you've ever
touched was an **archive**: many files packed into one,
usually shrunk on the way. This guide takes that file
apart — how it's built, how to look inside before
opening it, what comes back out the other side, and the
ways an archive from a stranger can misbehave.

"Making an archive" is two jobs, not one. **tar** packs
a tree into a single file, keeping its structure,
permissions, and links. **gzip** (or bzip2, xz, zstd)
shrinks a single stream of bytes. The `.tar.gz` you meet
every day is the pipeline of both — and once that clicks,
the rest of the subject is details. This guide covers
the details with the receipts attached, including the
chapter most archive guides skip: the extraction-safety
one, where archives built to escape their directory are
opened in a lab and the tools' refusals are quoted
verbatim.

If you know this series' *Backups* guide: that one is
the strategy — what to copy, how often, where to keep
it. This one is the mechanics underneath it.

It assumes you can use a terminal and make folders.
Everything archive-specific — modes, members, the
leading-slash rule, setuid bits — is explained from
zero.

## What this guide covers

- [**Two jobs, one tool**](what-archives-are.md) —
  archiving vs. compression, and the suffix table decoded
- [**Tar's grammar**](tar-grammar.md) — c/x/t, f, v,
  the letter bundles, and reading a listing as a table
- [**Creating archives**](creating-archives.md) —
  relative vs. absolute paths, and `--exclude` proven
  from the listing
- [**List before you extract**](list-before-you-extract.md) —
  the standing rule, and the tar bomb it defuses
- [**Compression, compared honestly**](compression-compared.md) —
  gzip, bzip2, xz, and zstd measured on one corpus
- [**gzip on its own**](gzip-on-its-own.md) — one file
  at a time, the `-k` habit, levels measured
- [**zip, the other ecosystem**](zip-the-other-ecosystem.md) —
  per-file compression, and the symlink it followed home
- [**Round trips and checksums**](round-trips-and-checksums.md) —
  proving an archive rebuilds its tree, and that the
  file that arrived is the file that left
- [**Permissions and ownership**](permissions-and-ownership.md) —
  who extracts decides what comes back; the setuid row
  watched carefully
- [**Extraction safety**](extraction-safety.md) —
  `..` members, absolute paths, and the symlink door,
  all opened in a lab
- [**Streaming and pipes**](streaming-and-pipes.md) —
  an archive with no file, checksums on streams, and the
  ssh form
- [**Special files**](special-files.md) — sparse files,
  hard links, and the members that aren't plain files
- [**Troubleshooting**](troubleshooting.md) —
  symptom → fix, with the real error messages
- [**Glossary**](glossary.md) — the terms, collected in
  one place

## What it doesn't cover

Backup strategy and tools (the *Backups* guide owns
that: restic, Borg, the 3-2-1 rule), encryption —
an archive is packed, not sealed, and zip's legacy
password option is not protection; see the *OpenSSL*
guide for the real machinery — and incremental-backup
systems. Tape drives are tar's birthplace and are
mentioned only there.

## How to use this guide

Everything was run for real with GNU tar 1.35, gzip
1.12, xz 5.4.5, bzip2 1.0.8, zstd 1.5.5, and Info-ZIP
zip 3.0 / unzip 6.00, against a fixture corpus the
shipped `examples/make-corpus.sh` rebuilds exactly:
forty small notes, three generated logs, and one file of
random bytes that no compressor can shrink. Every size
and time in the compression chapter is that corpus on
that machine, and the chapters say so. Two things the
build machine would not do are flagged where they
belong: its kernel refuses `chown()` even for root (so
root extractions here complain about ownership while
the modes land exactly as captured — chapter 9 explains),
and its sandbox resets ssh sessions, so tar-over-ssh is
written as the local pipe's identical shape and marked
**(documented)**. `criteria.md` keeps the full ledger.
