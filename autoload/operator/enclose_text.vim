
function! operator#enclose_text#append(motion) "{{{
  call enclose_text#edit_enclosure(a:motion, 'append', 0)
endfunction "}}}

function! operator#enclose_text#delete(motion) "{{{
  call enclose_text#edit_enclosure(a:motion, 'delete', 0)
endfunction "}}}

function! operator#enclose_text#change(motion) "{{{
  call enclose_text#edit_enclosure(a:motion, 'change', 0)
endfunction "}}}

