#!/bin/bash

for m in detailed/*; do
  if [ -d "$m" ]; then
    echo "Processing directory: $m"
    for archive in "$m"/*.tar.zst; do
      if [ -f "$archive" ]; then
        echo "  - Decompressing $archive"
        tar --zstd -xf "$archive" -C "$m" && rm "$archive"
      fi
    done
  fi
done

echo "Decompression finished."
