# summarise_yt
Retrieves auto-generated subtitles from youtube videos, cleans/sanitises/deduplicates the vtt, sends to clipboard to then be sent to summarising agent. No more wasted time on bla bla videos.

Requires:
yt-dlp, xclip or wl-copy

installation:
git clone blabla
don't forget to chmod +x

func for zshrc, etc, need to adapt script location:
summarise_yt() {
    if [ -z "$1" ]; then
        echo "Usage: summarise_yt <youtube-url>"
        return 1
    fi
    ./summarise.sh "$1"
}

