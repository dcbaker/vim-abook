if exists("loaded_vim_abook")
    finish
endif
let loaded_vim_abook = 1

" Function: QueryAbook()
"
" This function basically just calls abook --mutt-query with some special
" format options, and then presents a set of vim choices.
"
" This also works around a bug in abook, whic is documented in the function
" itself
"
" Args:
"    - name: The name or partial name of the person to lookup
"
" Sideeffect:
"    - Presents a list of names matching the partial name for the user to
"    select one
function! s:AbookQuery(name)
    " The XXXXX and YYYYY are sentinals for the regex that follows
    let l:raw_choices = system("abook --mutt-query " . a:name . " --outformat custom --outformatstr 'YYYYY<{name}> {email}XXXXX'")

    " Abook seems to have a bug related to custom output formats, it puts
    " gibberish at the front of each line when using "--outformat custom"
    " (which can contain the newline character. These three regex that follow
    " remove the sentinals and all of the text between them to make the lines
    " formatted
    let l:raw_choices = substitute(l:raw_choices, 'XXXXX\n.\{-}YYYYY', '\n', "g")
    let l:raw_choices = substitute(l:raw_choices, '^.*YYYYY', '', "")
    let l:raw_choices = substitute(l:raw_choices, 'XXXXX.*$', '', "")
    let l:choices = split(l:raw_choices, "\n")

    " Since inputlist will default to 0, making the count start at 1 (and
    " using the if statement at the end), means that just pressing enter will
    " cancel
    let l:i = 1
    let l:display_choices = ["Which address do you want (empty cancels):"]

    " Create a list of choices with a number prefaced on them
    for l:c in l:choices
        call add(l:display_choices, l:i . ": " . c)
        let l:i += 1
    endfor

    call inputsave()
    let l:choice = inputlist(l:display_choices)
    call inputrestore()

    if l:choice > 0
        " Choices index is 1 less than display_choices, and fixing it here
        " allows 0 to be cancel
        put =l:choices[l:choice - 1]
    endif
endfunction

" Function: s:AbookQueryINS()
"
" This function grabs the current word and replaces it with a value from
" AbookQuery
function! s:AbookQueryINS()
    normal b"bdE
    let l:partial = @b
    call s:AbookQuery(l:partial)
endfunction

command! -nargs=1 AbookQuery call <sid>AbookQuery(<f-args>)

inoremap <script> <leader>s <esc>:call <sid>AbookQueryINS()<cr><ins>
