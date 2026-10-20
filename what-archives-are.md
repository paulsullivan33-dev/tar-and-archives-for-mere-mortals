# Two Jobs, One Tool

**Scope:** the distinction the whole guide stands on.
"Making an archive" is two separate jobs that happen to
travel together — and most confusion about `.tar.gz` files
is just those two jobs being mistaken for one.

## Job one: archiving

An **archive** packs many files into one file while
keeping what makes them a tree: the directory structure,
the names, the permissions, the timestamps, the symlinks.
One file is easy to copy, send, checksum, and store; a
tree of four hundred files is none of those things.

The tool that does this job is **tar** — its name is
short for *tape archive*, from the era when the one file
went onto a reel of tape. The format outlived the tape.

## Job two: compression

**Compression** makes a file smaller by encoding
repetition more cheaply. `gzip`, `bzip2`, `xz`, and `zstd`
do this job. They know nothing about trees: each one
takes exactly one stream of bytes in and puts a smaller
stream out.

## The pipeline is the tool

Everyday archiving runs both jobs as a pipeline: tar
packs the tree into one stream, a compressor shrinks the
stream. That is all a `.tar.gz` is — a tar archive that
was passed through gzip on its way to disk.

| Name | What's inside |
|---|---|
| `backup.tar` | tar only. Full size, no compression |
| `backup.tar.gz` / `backup.tgz` | tar, then gzip |
| `backup.tar.bz2` | tar, then bzip2 |
| `backup.tar.xz` | tar, then xz |
| `backup.tar.zst` | tar, then zstd |
| `backup.zip` | a different format entirely — chapter 7 |

Two consequences worth carrying through the guide:

- **A compressor alone cannot archive.** `gzip` on a
  directory refuses politely; it shrinks one file at a
  time (chapter 6). When someone says "tar it up," this
  pipeline is what they mean.
- **Random data does not shrink.** Compression eats
  repetition. The lab corpus in this guide deliberately
  includes a file of pure random bytes so you can watch
  every compressor fail on it equally — measured, in
  chapter 5.

## Where this guide sits

This is the mechanics guide. The companion *Backups for
Mere Mortals* is the strategy guide — what to copy, how
often, where to keep it, how to prove a restore works.
Here, we take the archive itself apart: how tar's grammar
works, how to look inside before opening, what extraction
really does to permissions, and the ways an archive from
a stranger can bite — with the receipts for each.

**Check:** you should be able to say what the two jobs
are, and which tool does each. If `backup.tar.xz` reads
as "a tree, packed by tar, shrunk by xz," you're ready
for the grammar.
