
function! operator#enclose_text#append(motion) "{{{
  call enclose_text#edit_enclosure(a:motion, 'append')
endfunction "}}}

function! operator#enclose_text#delete(motion) "{{{
  call enclose_text#edit_enclosure(a:motion, 'delete')
endfunction "}}}

function! operator#enclose_text#change(motion) "{{{
  call enclose_text#edit_enclosure(a:motion, 'change')
endfunction "}}}

function! operator#enclose_text#append_each(motion) "{{{
  call enclose_text#edit_enclosure_each(a:motion, 'append')
endfunction "}}}

function! operator#enclose_text#delete_each(motion) "{{{
  call enclose_text#edit_enclosure_each(a:motion, 'delete')
endfunction "}}}

function! operator#enclose_text#change_each(motion) "{{{
  call enclose_text#edit_enclosure_each(a:motion, 'change')
endfunction "}}}

