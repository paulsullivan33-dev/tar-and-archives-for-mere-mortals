# Round Trips and Checksums

**Scope:** proving an archive is good — before you need
it, and after it crosses a network. Two different proofs:
the round trip (does it rebuild the tree?) and the
checksum (is this the same file that left?).

## The round trip

Extract somewhere else and compare the trees. Contents
byte-for-byte:

```console
$ mkdir -p elsewhere && tar -xzf out/corpus.tar.gz -C elsewhere
$ diff -r corpus elsewhere/corpus && echo "TREES IDENTICAL"
TREES IDENTICAL
```

`diff -r` walking away silent — followed here by our own
marker — is the whole test. If the archive is ever your
only copy of something, this is the proof that separates
"has a backup" from "has a file" (the Backups guide's
restore-testing chapter builds the habit out at length;
this is its smallest form). One boundary to know:
`diff -r` compares *contents*, not modes, owners, or
timestamps. When those matter, compare `tar -tvf`
listings of the original and a re-archive of the copy —
chapter 9's table is the same idea read by eye.

## The checksum

A **checksum** is a short fingerprint computed from a
file's bytes. Same bytes in, same fingerprint out; one
byte different, completely different fingerprint.

```console
$ sha256sum out/corpus.tar.gz | tee out/corpus.tar.gz.sha256
9dafd4a25a9043dd0558909f8ba88d923f01492215ee573c1b8e876babd4b9d7  out/corpus.tar.gz
$ sha256sum -c out/corpus.tar.gz.sha256
out/corpus.tar.gz: OK
```

Send the `.sha256` alongside the archive whenever the
archive travels — email, a file share, a release page.
The receiver's `sha256sum -c` answers the only question
that matters about a download: *is this the file that
left?* And the tamper case, caught in the lab by
changing exactly one byte of a copy:

```console
$ sha256sum tampered.tar.gz
ab0968c113a4371f59893fd197d2062c6cc4f3396078c30c70a314c79effbe63  tampered.tar.gz
```

One byte, unrecognisable fingerprint. When a checksum
mismatches, the move is to re-fetch the file — never to
"try extracting anyway and see": a mismatched archive is
either damaged or not the file you were promised, and
extraction can't tell you which.

A checksum is not a signature. It proves the file
matches a number; it says nothing about whether the
number itself came from someone you trust — for that,
the number has to arrive by a channel you trust, or be
signed (the OpenSSL guide covers the machinery).

**Check:** make an archive of something real, checksum
it, extract it elsewhere, and run the round trip. Then
flip one byte in a copy (`printf X | dd of=copy bs=1
seek=5000 conv=notrunc`) and watch the checksum catch
what your eye never would.
