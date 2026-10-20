# List Before You Extract

**Scope:** the standing rule of this guide, and the two
questions a listing answers. Everything in the safety
chapter assumes you did this first.

## The rule

**Never extract an archive you haven't listed.** `tar -tf`
costs a second, changes nothing, and answers the only
questions that matter before files start landing:

1. **Where will it land?** Is there one top folder, or do
   the members spill straight into the current directory?
2. **What else is in it?** Paths with `..` in them,
   absolute paths, symlinks pointing somewhere odd —
   chapter 10's specimens are all visible right here.

## The well-mannered archive

```console
$ tar -tf out/corpus.tar | head -12
corpus/
corpus/notes/
corpus/notes/note-01.txt
corpus/notes/note-02.txt
...
```

Every member lives under `corpus/`. Extract this
anywhere and you get exactly one new folder. Archives
built the chapter-3 way — `cd` to the parent, name the
folder — always look like this, which is why that shape
is the house style.

## The tar bomb

The opposite shape has a name in the folklore: a **tar
bomb** is an archive with no top folder, whose members
are loose files and directories. Extracted in your home
directory, it scatters itself through everything already
there — and two archives' `README.txt` files quietly
overwrite each other. Nothing about it is malicious; the
maker just archived `.` instead of a folder. It's still
a mess, and the listing is where you spot it: no common
first component.

The habits that cover both shapes, well-mannered and
not:

- **List first** (`tar -tf`, or `tar -tvf` when owners
  and permissions matter — chapter 9).
- **Extract into a fresh, empty directory** you made for
  the purpose: `mkdir unpack && tar -xf file.tar.gz -C unpack`.
  A bomb in an empty room is a shrug; a bomb in your
  home directory is an afternoon.

**Check:** take any archive on your machine and, from
the listing alone, say its top folder — or that it
doesn't have one. Then extract it in a scratch directory
and confirm the listing didn't lie.
