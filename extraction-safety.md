# Extraction Safety

**Scope:** the chapter that justifies the guide. An
archive is a set of instructions — *write these bytes
to these paths with these modes* — and extracting one
is executing it. Modern tools refuse the worst
instructions, and the lab below proves which ones, with
archives built to misbehave.

The specimens were built with Python's `tarfile` and
`zipfile`, because the easy tools happily *write*
dangerous members that GNU tar would never create. Each
was extracted inside a sacrificial directory tree;
nothing outside the lab was at stake.

## Specimen 1: the .. member

Members named `../escape.txt` and `../../deep-escape.txt`
aim above the extraction directory. Listing shows them
(with tar grumbling already):

```console
$ tar -tf out/evil-paths.tar
tar: Removing leading `../' from member names
../escape.txt
innocent.txt
tar: Removing leading `../../' from member names
../../deep-escape.txt
```

Extraction is where the refusal lands:

```console
$ cd victim/inner && tar -xf ../../out/evil-paths.tar; echo "exit: $?"
tar: ../escape.txt: Member name contains '..'
tar: ../../deep-escape.txt: Member name contains '..'
tar: Exiting with failure status due to previous errors
exit: 2
```

GNU tar 1.35 will not write a `..` member, full stop.
The innocent member in the same archive still extracts —
the refusal is per-member, not per-archive.

## Specimen 2: the absolute member

A member named `/tmp/lab-abs-escape.txt`:

```console
$ tar -xf out/evil-absolute.tar -C victim/abs
tar: Removing leading `/' from member names
$ ls /tmp/lab-abs-escape.txt
ls: cannot access '/tmp/lab-abs-escape.txt': No such file or directory
$ find victim/abs
victim/abs
victim/abs/tmp
victim/abs/tmp/lab-abs-escape.txt
```

The leading `/` is stripped and the member lands
*inside* the extraction directory, wearing its path as
folders. Nobody's `/tmp` was touched. (Both behaviours
have an override, `--absolute-paths`, whose existence is
a reason to never type flags you haven't looked up.)

## Specimen 3: the symlink door

The subtle one: first a symlink member pointing outside
the tree, then a file member addressed *through* it —
`door -> ../target`, followed by `door/through.txt`.
Tools that extract naively in order write the file into
`target/`, wherever that is.

```console
$ tar -tvf out/evil-link.tar
lrw-r--r-- 0/0  0 … door -> ../target
-rw-r--r-- 0/0 28 … door/through.txt
$ tar -xf out/evil-link.tar -C victim; echo "exit: $?"
tar: door/through.txt: Cannot open: Not a directory
tar: Exiting with failure status due to previous errors
exit: 2
```

GNU tar created the symlink — and then refused to write
through the link it had just planted. `target/` stayed
empty. This protection is version-dependent in the wider
world (older tars and other implementations have fallen
for this exact shape), which is why the habits below
don't rest on any single tool's good behaviour.

## Specimen 4: the zip version

`unzip` answers the same `..` member differently — it
sanitises instead of refusing:

```console
$ cd victim && unzip -o ../out/evil-paths.zip; echo "exit: $?"
warning:  skipped "../" path component(s) in ../zip-escape.txt
 extracting: zip-escape.txt
 extracting: innocent.txt
exit: 1
```

The escaping file lands *flat* in the current directory,
with a warning and a non-zero exit. Nothing left the
directory — but note the difference in philosophy: tar
refused the member; unzip rewrote its name. Either way,
the exit code told on it, which is a reason to read exit
codes and warnings instead of scrolling past them.

## The habits that cover all of it

The captures above are one build of one tool. Archives
in the wild meet older tools, other tools, and formats
without these checks. The habits that don't depend on
any of them:

1. **List first** (chapter 4). Every specimen in this
   chapter is visible in the listing before it can do
   anything.
2. **Extract into a fresh, empty directory.** Worst
   case, the damage has a fence around it.
3. **Don't extract untrusted archives as root.** As a
   normal user you can't write outside your own files
   even if a tool slips; as root, chapter 9 showed what
   comes back — owners, modes, setuid bits and all.
4. **Respect the exit code.** Both refusals above exited
   non-zero and said why. A script that ignores that is
   the vulnerability, not the archive.

**Check:** rebuild trust in your own setup — list a
downloaded archive before opening it, and find its top
folder, its biggest member, and any member containing
`..` or starting with `/`. Thirty seconds, every time.
