#!/bin/sh
# make-corpus.sh — build the deterministic fixture tree used by every
# chapter of Tar & Archives for Mere Mortals.
#
# Usage:  sh make-corpus.sh [target-dir]     (default: ./corpus)
#
# The tree mixes the shapes archives actually meet:
#   - many small text files          (notes/)
#   - a few larger compressible logs (logs/, generated text)
#   - one incompressible file        (data/random.bin, from /dev/urandom)
#   - an executable script           (bin/run.sh, mode 755)
#   - a private file                 (secret.txt, mode 600)
#   - an empty directory             (empty-dir/)
#   - a symlink                      (latest -> notes)
#   - scratch files to exclude       (notes/*.tmp)
# Everything except random.bin is byte-for-byte reproducible.
# random.bin is random by design: compressors cannot shrink noise,
# and the chapters need one file that proves it.

set -eu
dir=${1:-corpus}

rm -rf "$dir"
mkdir -p "$dir/notes" "$dir/logs" "$dir/data" "$dir/bin" "$dir/empty-dir"

printf 'Corpus for the tar & archives lab.\nEvery file here was made by make-corpus.sh.\n' \
  > "$dir/README.txt"

# 40 small text files, plus 3 scratch files the --exclude chapter removes.
i=1
while [ $i -le 40 ]; do
  printf 'note %02d\nline two of note %02d: the archive keeps the tree, not just the files.\n' \
    "$i" "$i" > "$dir/notes/note-$(printf '%02d' "$i").txt"
  i=$((i + 1))
done
for n in a b c; do
  printf 'scratch work, not worth archiving\n' > "$dir/notes/draft-$n.tmp"
done

# Three larger, very compressible logs: 9000 generated lines each.
for f in 1 2 3; do
  n=1
  while [ $n -le 9000 ]; do
    printf '2026-10-20T09:%02d:%02d INFO  worker-%d request handled in %d ms (status 200)\n' \
      $((n % 60)) $((n % 60)) "$f" $((n % 97))
    n=$((n + 1))
  done > "$dir/logs/app-$f.log"
done

# One incompressible file: 256 KiB of random bytes.
dd if=/dev/urandom of="$dir/data/random.bin" bs=1024 count=256 2>/dev/null

printf '#!/bin/sh\necho "fixture script, mode 755"\n' > "$dir/bin/run.sh"
chmod 755 "$dir/bin/run.sh"

printf 'fixture secret, mode 600. tar remembers these bits.\n' > "$dir/secret.txt"
chmod 600 "$dir/secret.txt"

ln -s notes "$dir/latest"

echo "corpus built in $dir"
