
command! -range EncloseAppend call enclose_text#edit_enclosure_command('append', 'block')
command! -range EncloseDelete call enclose_text#edit_enclosure_command('delete', 'block')
command! -range EncloseChange call enclose_text#edit_enclosure_command('change', 'block')

command! -range EncloseAppendEach call enclose_text#edit_enclosure_command('append', 'each')
command! -range EncloseDeleteEach call enclose_text#edit_enclosure_command('delete', 'each')
command! -range EncloseChangeEach call enclose_text#edit_enclosure_command('change', 'each')

