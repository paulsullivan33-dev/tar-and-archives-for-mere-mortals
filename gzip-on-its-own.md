# gzip on Its Own

**Scope:** the compressor without tar — one file at a
time. This is the tool behind log rotation, `.sql.gz`
database dumps, and every "download the gzipped release"
link.

## The one-file contract

`gzip` shrinks a single file and, by default, *replaces*
it: `app.log` becomes `app.log.gz` and the original is
gone. `-k` keeps the original, and it's the flag to
build the habit around:

```console
$ cp corpus/logs/app-1.log single.log && ls -l single.log
-rw-rw---- 1 root nogroup 656071 … single.log
$ gzip -k single.log && ls -l single.log single.log.gz
-rw-rw---- 1 root nogroup 656071 … single.log
-rw-rw---- 1 root nogroup  36832 … single.log.gz
```

656,071 bytes of near-identical log lines became
36,832 — a 94% saving, far beyond the mixed corpus's
blended 16% in chapter 5. That's the two chapters
agreeing: compression eats repetition, a uniform log is
almost all repetition, and the corpus number was floored
by its random file. Your files will sit wherever their
own repetition puts them.

`gzip -l` reports on a `.gz` without touching it:

```console
$ gzip -l single.log.gz
         compressed        uncompressed  ratio uncompressed_name
              36832              656071  94.4% single.log
```

## Coming back — and the refusal

Decompression has the same replacement contract in
reverse, plus a safety catch worth meeting in the lab
instead of in production:

```console
$ gunzip -k single.log.gz
gzip: single.log already exists;	not overwritten
```

The uncompressed name already exists — because `-k`
kept it there — so `gunzip` refuses rather than
overwrite it. Delete or rename the existing file, or
add `-f` when you're certain, and it proceeds. The
mirror-image rule holds on the compress side: `gzip`
won't silently replace an existing `.gz` either.

(`zcat file.gz`, or `gunzip -c`, streams the
uncompressed bytes to stdout without writing a file at
all — the form chapter 11's pipes are built from.)

## Levels: -1 to -9

gzip's dial runs from `-1` (fast, loose) to `-9` (slow,
tight), defaulting to `-6`. Measured on the same log:

```console
$ gzip -9 -k -f single.log && ls -l single.log.gz
-rw-rw---- 1 root nogroup 31848 … single.log.gz
```

Level 9 bought 36,832 → 31,848 bytes — about 14%
smaller — for its extra passes. The usual shape of the
trade: the default level does the heavy lifting, the top
of the dial squeezes what remains. Reach for `-9` for a
file you'll compress once and ship a thousand times;
leave the default for everything routine.

What gzip will never do, by design: several files at
once, directory trees, or preserving a tree's shape.
That was never its job — it is job two from chapter 1,
and tar does job one before handing over.

**Check:** find a `.gz` already on your machine, run
`gzip -l` on it, and compare its ratio to the lab log's
94.4%. The gap between the two numbers *is* the chapter:
it's about what's inside, not which tool you picked.
