#!/usr/bin/env bash

# Exit if any command fails
set -euo pipefail

# --- Use ~/temp as working directory ---
WORKDIR="$HOME/temp"
mkdir -p "$WORKDIR"
echo "Using home temp directory: $WORKDIR"
cd "$WORKDIR"

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
yt-dlp --cookies-from-browser firefox --write-auto-subs --skip-download "$URL"

# Grab latest .en.vtt
VTT_FILE=$(ls -t *.en.vtt | head -n 1)

# --- Step 2: Clean VTT into transcript.txt ---
sed -E 's/<[^>]*>//g' "$VTT_FILE" \
  | grep -vE "^[0-9]+$" \
  | grep -vE "^[0-9]{2}:" \
  | sed '/^\s*$/d' \
  > transcript.txt

# --- Step 3: Deduplicate lines ---
awk 'NR==1 || $0 != prev {print; prev=$0}' transcript.txt > transcript_clean.txt

# --- Step 4: Add prefix prompt ---
{
  echo "Summarize the following video transcript into a clear, factual narrative. Include only what is explicitly stated: events, actions, statements, or information from the transcript. Do not add any opinions, interpretations, assumptions, or extra commentary. Keep the summary coherent and readable as prose, focusing on the main points, and exclude any irrelevant details."
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

echo "All files saved in: $WORKDIR"
