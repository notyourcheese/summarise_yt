# summarise_yt
Retrieves auto-generated subtitles from youtube videos, cleans/sanitises/deduplicates the vtt, sends to clipboard to then be sent to summarising agent. No more wasted time on bla bla videos.  

Requires:  
yt-dlp, xclip or wl-copy  

installation:  
git clone blabla  
don't forget to chmod +x  

func for zshrc, etc, need to adapt script location, don't forget to source ~/.zshrc afterwards:  
```
summarise_yt() {
    if [[ -n "$1" ]]; then
        ./summarise.sh "$1"
    else
        ./summarise.sh
    fi
}
```

watch out for special chars; may need quotes around url to properly pass argument
