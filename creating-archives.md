# Creating Archives: Paths and Exclusions

**Scope:** how the names get in — which decides where
they come back out. Two captures: the path you gave is
not always the path that's stored, and leaving things
out is a listing away from provable.

## Give relative paths; tar insists anyway

Archive from *next to* the tree, naming the tree itself:

```console
$ tar -cvf out/corpus.tar corpus
```

Members are stored as `corpus/notes/note-01.txt` — paths
relative to where you stood. That top-level folder is a
gift to whoever extracts it later (chapter 4).

Feed tar an absolute path and it pushes back, on
purpose:

```console
$ tar -cvf out/abs.tar /home/hatch/workspace/tar-archives-lab/work/corpus/secret.txt
tar: Removing leading `/' from member names
/home/hatch/workspace/tar-archives-lab/work/corpus/secret.txt

$ tar -tf out/abs.tar
home/hatch/workspace/tar-archives-lab/work/corpus/secret.txt
```

The leading `/` is stripped and the warning says so.
The reason is defensive: an archive whose members are
absolute paths would extract *onto those paths* on any
machine that opened it. Since GNU tar refuses to build
such archives by default (and refuses to honour them on
the way out — chapter 10), an absolute-path archive
degrades to a very long relative one. The practical
lesson is unchanged: `cd` to the parent and archive the
folder's name, so the stored paths are short and the
intent is obvious.

## Leaving things out: --exclude

`--exclude` takes a pattern matched against member
names:

```console
$ tar -cvf out/no-tmp.tar --exclude="*.tmp" corpus
$ tar -tf out/no-tmp.tar | grep -c "tmp" ; tar -tf out/corpus.tar | grep -c "tmp"
0
3
```

```console
$ tar -cvf out/no-logs.tar --exclude="corpus/logs" corpus
$ tar -tf out/no-logs.tar | grep -c "logs/"
0
```

Two habits ride along:

- **Prove the exclusion from the listing**, not from the
  create output. The count above is the proof; scrolling
  `-v` output is a hope.
- **Mind what the pattern anchors to.** `*.tmp` matched
  anywhere in the tree; `corpus/logs` matched that exact
  directory. Run `tar -tf` and look at the names before
  writing the pattern, because the pattern is matched
  against *member names*, not filesystem paths.

**Check:** build two archives of the corpus — one with
`--exclude="*.tmp"`, one without — and make the listings
disagree by exactly the three draft files.
