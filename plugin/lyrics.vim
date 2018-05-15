"Author: Genesis Guerrero. Apr 18, 2018
"Inspited by lyrcs.vim from Humberto H. C. Pinheiro Qua 

if exists("g:loaded_lyrics") || &cp
    finish
endif
let g:loaded_lyrics = 0.0.1

let cpo_save = &cpo
set cpo-=C

" --------------------------------------------------------------------------
"
let s:lyrics_site = "https://makeitpersonal.co/lyrics?artist=xartistx&title=song"

" --------------------------------------------------------------------------

fun! s:DownloadLyrics(url)
    let url = substitute(a:url, '\ ', '%20', "g")
    let html = system("curl -s \"" . url . "\"")
    return html
endfun

fun! s:ShowLyrics(song, artist)
    let url            = s:lyrics_site
    let url            = substitute(url, 'song', a:song, "g")
    let url            = substitute(url, 'xartistx', a:artist, "g")
    let lyrics         = s:DownloadLyrics(url)
    botright new
    setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap paste
    silent! execute "normal! a " . a:song . " - " . a:artist . "\n\n" . lyrics
    silent! execute "normal! gg"
    setlocal nopaste
endfun

fun! s:SpotifyLyrics()
    let currentPlaying = system("spotify status")
    if currentPlaying =~ "Spotify is currently paused."
        echo 'Spotify not playing'
        return
    endif
    let result = split(currentPlaying, '\n')
    let artist = substitute(result[1], '^\s\+\|\s\+$\|\r\n|\^\[^\[\[m|\b|\r', '', 'g')
    let song  = substitute(result[3], '^\s\+\|\s\+$\|\r\n', '', 'g')

    " Extrack only the values
    let artist = substitute(artist, 'Artist:', '', 'g')
    let artist = substitute(artist, '[\x01-\x1F\x7F]', '', 'g')
    let artist = substitute(artist, '\x1b\[.\{1,5\}m', '', 'g')
    let artist = substitute(artist, '^B\[m', '', 'g')
    let artist = substitute(artist, '^(B\[m', '', 'g')
    let artist = substitute(artist, '^\[m', '', 'g')
    let song  = substitute(song, 'Track:', '', 'g')
    let song  = substitute(song, '- Single Remix', '', 'g')

    call s:ShowLyrics(song, artist)
endfun

fun! s:SearchLyrics()
    call inputsave()
    let  inputStr       = input('Enter song-artist:    ')
    call inputrestore()
    let  [song, artist] = split(inputStr, '-')
    call s:ShowLyrics(song, artist)
endfun

command! Lyrics       call s:SpotifyLyrics()
command! SearchLyrics call s:SearchLyrics()

let &cpo = cpo_save
" -------------------------------------------------------------------------
