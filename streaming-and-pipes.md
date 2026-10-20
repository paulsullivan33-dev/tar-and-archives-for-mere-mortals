# Streaming and Pipes

**Scope:** tar's original habitat. Leave off the `f`,
or point it at `-`, and the archive becomes a stream —
written by one tar, read by another, with nothing on
disk in between.

## The pipe is a place

```console
$ tar -cf - corpus | tar --no-same-owner -xf - -C stream-out && diff -r corpus stream-out/corpus && echo "STREAMED TREE IDENTICAL"
STREAMED TREE IDENTICAL
```

`f -` on the left means "the archive is stdout"; `f -`
on the right means "read it from stdin." Two tars, one
pipe, and the tree arrives intact — the same round-trip
proof as chapter 8, with no archive file ever existing.
(The receiving end wears `--no-same-owner` for the
chapter-9 reason: skip the ownership step when you don't
need it.)

The stream is a real archive in every respect. Stream
the same unchanged tree twice and the bytes — not just
the contents — are identical, so checksums work on
streams exactly as on files:

```console
$ tar -cf - corpus | sha256sum; tar -cf - corpus | sha256sum
77184fcb6bc427fd9dca260315bd43408e75394b9302021a4666fad1d5c2f793  -
77184fcb6bc427fd9dca260315bd43408e75394b9302021a4666fad1d5c2f793  -
```

Compression rides the same pipe, since it's just a
filter in the middle:

```console
$ tar -czf - corpus | wc -c
378199
```

— precisely the size of the `corpus.tar.gz` *file* from
chapter 5. The pipeline doesn't care whether the stream
ends in a file, a checksum, a byte count, or another
machine.

## Over the network

That last one is the classic form:

```console
$ tar -cf - corpus | ssh user@otherbox "tar -xf - -C /backup"
```

ssh is simply the longest pipe: it carries the stream,
and a tar on the far side unpacks it as it arrives. No
temporary file on either end, nothing to clean up.

**(documented)** — this one is written from the shape of
the thing rather than a live run in this lab, and the
lab says why honestly: a private sshd does run on the
build machine (its log shows `Server listening on
127.0.0.1 port 2222`), but this sandbox resets session
connections before authentication completes
(`Connection reset by 127.0.0.1 port 2222`). The local
pipe above is captured live; the ssh hop is the same
command with the pipe lengthened, and the rsync guide's
*Over the Network* chapter covers the neighbouring tool
whose home ground this is.

**Check:** pipe a folder somewhere else on your own disk
through `tar | tar`, then prove it with `diff -r`. Once
that shape is in your fingers, every variant in this
chapter is a costume change.
