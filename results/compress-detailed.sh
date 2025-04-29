#!/bin/bash

for m in detailed/*; do
  if [ -d "$m" ]; then
    echo "Processing directory: $m"
    for r in "$m"/*; do
      if [ -d "$r" ]; then
        echo "  - Compressing $r"
        tar --zstd -cf "$r.tar.zst" -C "$m" $(basename "$r") && rm -r "$r"
      fi
    done
  fi
done

echo "Compression finished."
