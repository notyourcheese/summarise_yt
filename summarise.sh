#!/usr/bin/env bash

# Exit if any command fails
set -euo pipefail

# --- Step 0: Determine URL ---
if [[ $# -ge 1 ]]; then
  URL="$1"
else
  # Try to grab from clipboard
  if command -v wl-paste &>/dev/null; then
    URL=$(wl-paste)
  elif command -v xclip &>/dev/null; then
    URL=$(xclip -o -selection clipboard)
  else
    echo "Error: No argument provided and no clipboard tool found (need wl-paste or xclip)." >&2
    exit 1
  fi
fi

# --- Step 0.5: Validate URL ---
if [[ -z "$URL" ]]; then
  echo "Error: No URL provided and clipboard was empty." >&2
  exit 1
elif ! [[ "$URL" =~ ^https?:// ]]; then
  echo "Error: Invalid URL detected → '$URL'" >&2
  exit 1
fi

# --- Step 1: Download auto subtitles only ---
yt-dlp --write-auto-subs --skip-download "$URL"

# Grab the most recent .en.vtt file (yt-dlp writes it in the current dir)
VTT_FILE=$(ls -t *.en.vtt | head -n 1)

# --- Step 2: Clean up the .vtt into transcript.txt ---
sed -E 's/<[^>]*>//g' "$VTT_FILE" \
  | grep -vE "^[0-9]+$" \
  | grep -vE "^[0-9]{2}:" \
  | sed '/^\s*$/d' \
  > transcript.txt

# --- Step 3: Deduplicate consecutive duplicate lines → transcript_clean.txt ---
awk 'NR==1 || $0 != prev {print; prev=$0}' transcript.txt > transcript_clean.txt

# --- Step 4: Add "please summarise this for me:" prefix ---
{
  echo "please summarise this for me:"
  cat transcript_clean.txt
} > to_clipboard.txt

# --- Step 5: Copy to clipboard ---
if command -v wl-copy &>/dev/null; then
  wl-copy < to_clipboard.txt
  echo "Copied transcript to clipboard (Wayland)"
elif command -v xclip &>/dev/null; then
  xclip -selection clipboard < to_clipboard.txt
  echo "Copied transcript to clipboard (X11)"
else
  echo "Neither wl-copy nor xclip found!" >&2
fi
