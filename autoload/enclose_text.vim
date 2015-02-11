if get(g:, 'enclose_text#no_default_enclosure_table', 0)
  let s:enclose_enclosure_table = get(g:, 'g:enclose_text#enclosure_table', {})

else
  function! s:merge_table(base, overload) "{{{
    for [l:type, l:blocks] in items(a:overload)
      if has_key(a:base, l:type)
        call extend(a:base[l:type], l:blocks)
      else
        let a:base[l:type] = l:blocks
      endif
    endfor

    return a:base
  endfunction "}}}

  let s:enclose_enclosure_table = s:merge_table({
        \ '_': {
        \   '(': { 'from': [ '( *', ' *)' ], 'to': [ '( ', ' )' ] },
        \   '[': { 'from': [ '[ *', ' *]' ], 'to': [ '[ ', ' ]' ] },
        \   '{': { 'from': [ '{ *', ' *}' ], 'to': [ '{ ', ' }' ] },
        \   '<': { 'from': [ '< *', ' *>' ], 'to': [ '< ', ' >' ] },
        \   ')': { 'to': [ '(', ')' ] },
        \   ']': { 'to': [ '[', ']' ] },
        \   '}': { 'to': [ '{', '}' ] },
        \   '>': { 'to': [ '<', '>' ] },
        \   "'": { 'to': [ "'", "'" ] },
        \   '"': { 'to': [ '"', '"' ] },
        \   '`': { 'to': [ '`', '`' ] }
        \   }
        \ }, get(g:, 'g:enclose#enclosure_table', {}))

  delfunction s:merge_table
endif

function! enclose_text#complete(arg_lead, cmdline, cursor_pos) "{{{
  let l:filetype = &filetype

  if has_key(s:enclose_enclosure_table, l:filetype)
    let l:candidates = keys(s:enclose_enclosure_table[l:filetype])
  else
    let l:candidates = []
  endif

  return extend(keys(s:enclose_enclosure_table._), l:candidates)
endfunction "}}}

function! s:text_split3(text, pos1, pos2) "{{{
  return [
        \ strpart(a:text, 0, a:pos1 -1 ),
        \ strpart(a:text, a:pos1 -1, a:pos2 - a:pos1 + 1),
        \ strpart(a:text, a:pos2)
        \ ]
endfunction "}}}

function! s:text_part_edit_both(text, pos, enclosure) "{{{
  if len(a:text) < a:pos.begin
    return a:text
  else
    let l:parts = s:text_split3(a:text, a:pos.begin, a:pos.end)
    let l:parts[1] = s:text_edit_both(l:parts[1], a:enclosure)

    return join(l:parts, '')
  endif
endfunction "}}}

function! s:text_edit_head(text, enclosure) "{{{
  return substitute(a:text, a:enclosure.from.open, a:enclosure.to.open, '')
endfunction "}}}

function! s:text_edit_tail(text, enclosure) "{{{
  return substitute(a:text, a:enclosure.from.close, a:enclosure.to.close, '')
endfunction "}}}

function! s:text_edit_both(text, enclosure) "{{{
  return s:text_edit_tail(s:text_edit_head(a:text, a:enclosure), a:enclosure)
endfunction "}}}

function! s:visual_edit_char(range, enclosure) "{{{
  if empty(a:enclosure)
    return
  endif

  let l:lines = getline(a:range.line.begin, a:range.line.end)

  if a:range.line.begin == a:range.line.end
    let l:parts = s:text_split3(l:lines[0], a:range.pos.begin, a:range.pos.end)
    let l:parts[1] = s:text_edit_both(l:parts[1], a:enclosure)
    let l:lines[0] = join(l:parts, '')

  else
    let l:parts = [
          \ strpart(l:lines[0], 0, a:range.pos.begin -1 ),
          \ strpart(l:lines[0], a:range.pos.begin -1)
          \ ]
    let l:parts[1] = s:text_edit_head(l:parts[1], a:enclosure)
    let l:lines[0] = join(l:parts, '')

    let l:parts = [
          \ strpart(l:lines[-1], 0, a:range.pos.end ),
          \ strpart(l:lines[-1], a:range.pos.end)
          \ ]
    let l:parts[0] = s:text_edit_tail(l:parts[0], a:enclosure)
    let l:lines[-1] = join(l:parts, '')

  endif

  call setline(a:range.line.begin, l:lines)

  if get(g:, 'enclose_text#delete_blank_line_after_edit', 0)
    execute printf('%dg/^\s*$/delete', a:range.line.end)
    execute printf('%dg/^\s*$/delete', a:range.line.begin)
  endif
endfunction "}}}

function! s:visual_edit_line_block(edit_mode, range, enclosure) "{{{
  if empty(a:enclosure)
    return
  endif

  if a:edit_mode ==# 'append'
    call append(a:range.line.end, [a:enclosure.to.close])
    call append(a:range.line.begin - 1, [a:enclosure.to.open])

  else " delete,change
    call setline(a:range.line.end, substitute(
          \ getline(a:range.line.end), a:enclosure.from.close, a:enclosure.to.close, ''))
    call setline(a:range.line.begin, substitute(
          \ getline(a:range.line.begin), a:enclosure.from.open, a:enclosure.to.open, ''))

    if get(g:, 'enclose_text#delete_blank_line_after_edit', 0)
      execute printf('%dg/^\s*$/delete', a:range.line.end)
      execute printf('%dg/^\s*$/delete', a:range.line.begin)
    endif

  endif
endfunction "}}}

function! s:visual_edit_line_each(range, enclosure) "{{{
  if empty(a:enclosure)
    return
  endif

  let l:lines = getline(a:range.line.begin, a:range.line.end)
  let l:lines = map(l:lines, 's:text_edit_both(v:val, a:enclosure)')

  call setline(a:range.line.begin, l:lines)
endfunction "}}}

function! s:visual_edit_block(range, enclosure) "{{{
  if empty(a:enclosure)
    return
  endif

  let l:lines = getline(a:range.line.begin, a:range.line.end)
  let l:lines = map(l:lines, 's:text_part_edit_both(v:val, a:range.pos, a:enclosure)')

  call setline(a:range.line.begin, l:lines)
endfunction "}}}

function! s:get_empty_from_enclosure() "{{{
  return { 'open': '^', 'close': '$' }
endfunction "}}}

function! s:get_empty_to_enclosure() "{{{
  return { 'open': '', 'close': '' }
endfunction "}}}

function! s:get_from_enclosure(pattern) "{{{
  if has_key(a:pattern, 'from')
    return {
          \ 'open': get(a:pattern.from, 0, '^'),
          \ 'close': get(a:pattern.from, 1, '$')
          \ }
  else
    if has_key(a:pattern, 'to')
      return {
            \ 'open': '^\V' . get(a:pattern.to, 0, ''),
            \ 'close': '\V' . get(a:pattern.to, 1, '') . '\$'
            \ }
    else
      return {}
    endif
  endif
endfunction "}}}

function! s:get_to_enclosure(pattern) "{{{
  if has_key(a:pattern, 'to')
    return {
          \ 'open': get(a:pattern.to, 0, ''),
          \ 'close': get(a:pattern.to, 1, '')
          \ }
  else
    return {}
  endif
endfunction "}}}

function! s:get_char()
  let c = getchar()

  if c =~# '^\d\+$'
    return nr2char(c)
  else
    return c
  endif
endfunction

function! s:count(list, pattern) "{{{
  let l:count = 0

  for l:item in a:list
    if l:item =~# a:pattern
      let l:count += 1
    endif
  endfor

  return l:count
endfunction "}}}

function! s:get_pattern(caption, table) "{{{
  let l:in_str = ''
  let l:candidates = enclose_text#complete('', '', 0)

  echo printf('enclosures: %s', join(l:candidates, ' ')) "\n" printf('input enclosure %s', a:caption)

  try
    while 1
      let l:in = s:get_char()

      if l:in =~# "\<Esc>" || l:in =~# "\<C-C>"
        echo 'edit enclosure canceled.'
        break
      endif

      let l:in_str .= l:in
      let l:count = s:count(l:candidates, '^\V'.l:in_str)

      if l:count < 2
        if l:count < 1
          echo 'edit enclosure not found.' . l:in_str
        endif

        break
      endif
    endwhile

  catch
    echo v:exception

    let l:in_str = ''

  endtry

  return get(a:table, l:in_str, {})
endfunction "}}}

function! s:get_enclosure_table() "{{{
  return extend(
        \ get(s:enclose_enclosure_table, &filetype, {}),
        \ get(s:enclose_enclosure_table, '_', {})
        \ )
endfunction "}}}

function! s:get_enclosure(edit_mode) "{{{
  if a:edit_mode ==# 'append'
    let l:from = s:get_empty_from_enclosure()
    let l:to = s:get_to_enclosure(s:get_pattern('to: ', s:get_enclosure_table()))

  elseif a:edit_mode ==# 'delete'
    let l:from = s:get_from_enclosure(s:get_pattern('from: ', s:get_enclosure_table()))
    let l:to = s:get_empty_to_enclosure()

  elseif a:edit_mode ==# 'change'
    let l:table = s:get_enclosure_table()
    let l:from = s:get_from_enclosure(s:get_pattern('from: ', l:table))
    let l:to = s:get_to_enclosure(s:get_pattern('to: ', l:table))
  else
    return {}
  endif

  if empty(l:from) || empty(l:to)
    return {}
  endif

  return { 'from': l:from, 'to': l:to }
endfunction "}}}

function! s:get_range(start, end) "{{{
  return {
        \ 'line': { 'begin': a:start[1], 'end': a:end[1] },
        \ 'pos': { 'begin': a:start[2], 'end': a:end[2] }
        \ }
endfunction "}}}

function! s:edit_enclosure(motion, range, edit_mode, line_mode) "{{{
  if a:motion ==# 'char'
    call s:visual_edit_char(a:range, s:get_enclosure(a:edit_mode))

  elseif a:motion ==# 'line'
    if a:line_mode ==# 'each'
      call s:visual_edit_line_each(a:range, s:get_enclosure(a:edit_mode))

    else
      call s:visual_edit_line_block(a:edit_mode, a:range, s:get_enclosure(a:edit_mode))

    endif

  elseif a:motion ==# 'block'
    call s:visual_edit_block(a:range, s:get_enclosure(a:edit_mode))

  else
    call s:visual_edit_char(a:range, s:get_enclosure(a:edit_mode))
  endif
endfunction "}}}

function! enclose_text#edit_enclosure(motion, edit_mode) "{{{
  let l:range = s:get_range(getpos("'["), getpos("']"))

  call s:edit_enclosure(a:motion, l:range, a:edit_mode, 'block')
endfunction "}}}

function! enclose_text#edit_enclosure_each(motion, edit_mode) "{{{
  let l:range = s:get_range(getpos("'["), getpos("']"))

  call s:edit_enclosure(a:motion, l:range, a:edit_mode, 'each')
endfunction "}}}

function! enclose_text#edit_enclosure_visual(edit_mode, line_mode) "{{{
  let l:mode = visualmode()

  if l:mode ==# 'v'
    let l:motion = 'char'

  elseif l:mode ==# 'V'
    let l:motion = 'line'

  elseif l:mode ==# ''
    let l:motion = 'block'
  else
    echo 'no range to operation.'
    return 
  endif

  let l:range = s:get_range(getpos("'<"), getpos("'>"))

  call s:edit_enclosure(l:motion, l:range, a:edit_mode, a:line_mode)
endfunction "}}}


