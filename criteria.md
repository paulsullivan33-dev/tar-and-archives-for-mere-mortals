# Writing Criteria

Every guide in this repo is written to the same standard. If you're
adding or editing a guide — human or AI — hold it to these.

1. **Plain words, real ideas.** Simple language, never dumbed-down
   concepts. Explain jargon on first use; collect terms in the
   glossary.
2. **No hype.** No marketing adjectives, no "revolutionary," no
   promises about what something will do for the reader.
3. **Honest about limits.** Say what the thing *can't* do. State
   uncertainty instead of smoothing it over. Validation notes include
   what remains unverified.
4. **No invented numbers.** Benchmarks, defaults, and specs are either
   measured or qualified with "depends on your setup." If it wasn't
   tested, say so.
5. **Checkable.** Commands are meant to be run, with "Check:" blocks
   showing what success looks like. Sources are linked, not asserted.
6. **Respect the reader's setup.** Call out Windows/Mac/Linux
   differences. Don't assume a GPU, a budget, or prior experience.
7. **Safety isn't skipped.** Real risks get stated plainly, not buried.
8. **Scoped.** Each guide says what it covers and points elsewhere for
   the rest. No guide pretends to be the whole subject.
9. **Structure over prose.** Tables, before/after examples,
   symptom → fix. Scannable beats essay.

## Verification appendix — this guide

Per point 4, what was actually run, on the build machine
(GNU tar 1.35, gzip 1.12, xz 5.4.5 / liblzma 5.4.5, bzip2
1.0.8, zstd 1.5.5, Info-ZIP zip 3.0 / unzip 6.00, python
3.12.3). Thirteen lab captures are kept in the lab
transcripts that accompany this guide's build.

**Live-captured:**

- Tool versions (transcript 01); the corpus built by the
  shipped `make-corpus.sh`, inventoried with `find`/`du`
  (02); create + `t`/`tv` listings, symlink and empty-dir
  members (03).
- Absolute-path creation: the `Removing leading '/'`
  warning and the stripped stored path; `--exclude` by
  pattern and by directory, each proven by listing
  counts (04).
- Compression comparison on the identical corpus — plain
  2,293,760 / gzip 378,199 (37 ms) / bzip2 299,947
  (591 ms) / zstd 285,128 (15 ms) / xz 279,312 (488 ms),
  single runs, stated as this-corpus results; flag-free
  reading of a `.tar.xz` (05).
- gzip alone: 656,071 → 36,832 B at default level,
  31,848 B at `-9`; `gzip -l` (94.4%); `gunzip -k`
  refusing to overwrite an existing file (06).
- zip: default `zip -r` following the corpus symlink and
  archiving all 40 notes a second time (zip = 395,718 B);
  `zip -ry` storing the link as a 5-byte member; `unzip`
  restoring the symlink and the empty directory (07).
- Round trip: extract elsewhere, `diff -r` silent
  ("TREES IDENTICAL"); `sha256sum` + `sha256sum -c` OK;
  a one-byte tamper producing a completely different
  fingerprint (08).
- Permissions: non-root extraction re-owning everything
  to the extractor, modes passing through umask 007
  (644→640, 755→750), setuid stripped by default and
  restored by `-p` (as the extractor's own uid); root
  `-p` extraction restoring modes including the 4755
  setuid bit; `--numeric-owner` showing 0/65534 (09).
- Extraction safety, all four specimens built with
  python tarfile/zipfile: GNU tar refusing `..` members
  ("Member name contains '..'", exit 2) while extracting
  the innocent member; absolute member stripped and
  landing inside the target, `/tmp` untouched; symlink-
  then-file refused at the write-through ("Cannot open:
  Not a directory", exit 2, target stayed empty); unzip
  sanitising the same `..` member flat with a warning,
  exit 1 (10).
- Streaming: `tar -cf - | tar -xf -` round trip with
  `diff -r` clean; two identical stream checksums;
  `tar -czf - | wc -c` = 378,199, byte-identical size to
  the file form (11).
- Sparse: 1,048,581-byte logical file at 8 KB on disk;
  naive archive 1,054,720 B vs `--sparse` 10,240 B; hard
  links listed with the `h` type and "link to", restored
  sharing one inode (7415033 → a fresh shared inode on
  extraction) (12).
- Failures: "file changed as we read it" (exit 1) from a
  live-appended 3-million-line log; truncated `.tar.gz`
  → gzip "unexpected end of file" + tar "Unexpected EOF"
  (exit 2); a zip fed to tar ("does not look like a tar
  archive"); a plain tar fed to `tar -tzf` ("not in gzip
  format", "Child returned status 1") (13).

**Documented-only:**

- **tar over ssh as a live transfer.** A lab sshd does
  start on this sandbox ("Server listening on 127.0.0.1
  port 2222") but session connections are reset before
  authentication ("Connection reset by 127.0.0.1 port
  2222") — both lines quoted verbatim in chapter 11. The
  command is given as the local pipe's identical shape,
  not as a captured run.
- **Root extraction restoring ownership silently.** This
  sandbox's kernel refuses `chown()` even for root
  ("Cannot change ownership to uid 0, gid 65534:
  Operation not permitted"), so root extractions here
  exit non-zero over ownership while modes land exactly
  as captured. On an ordinary machine the ownership
  restore succeeds silently — stated as standard
  behaviour in chapter 9, with the refusal disclosed in
  place rather than hidden.
- **Other platforms' tools** (BSD tar, macOS Archive
  Utility, Windows' built-in zip handling) are named
  only where behaviour is known to differ in kind (zip's
  audience), never demonstrated.
- **Encryption** is out of scope entirely (point 8):
  tar and zip's legacy password option are not taught,
  and the guide says where that subject lives instead.

**Build-side notes:** an early create capture was
destroyed by piping tar's create output into `head`
(SIGPIPE truncated the archive to zero bytes) — retaken
without the pipe; the permissions chapter's first draft
asserted that non-root `-p` extraction cannot restore
setuid bits, and the capture proved the opposite (with
`-p`, the full mode returns, owned by the extractor).
The chapter was rewritten to the capture. The corpus's
`random.bin` differs on every build by design; all other
fixtures are byte-identical across runs of
`make-corpus.sh`, and every size quoted in the chapters
was re-read from the transcripts before publication.
