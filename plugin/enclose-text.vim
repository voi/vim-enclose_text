
command! -range EncloseAppend call enclose_text#edit_enclosure_visual('append', 'block')
command! -range EncloseDelete call enclose_text#edit_enclosure_visual('delete', 'block')
command! -range EncloseChange call enclose_text#edit_enclosure_visual('change', 'block')

command! -range EncloseAppendEach call enclose_text#edit_enclosure_visual('append', 'each')
command! -range EncloseDeleteEach call enclose_text#edit_enclosure_visual('delete', 'each')
command! -range EncloseChangeEach call enclose_text#edit_enclosure_visual('change', 'each')

