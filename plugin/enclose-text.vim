
command! -range EncloseAppend call enclose_text#edit_enclosure_visual('append', 0)
command! -range EncloseDelete call enclose_text#edit_enclosure_visual('delete', 0)
command! -range EncloseChange call enclose_text#edit_enclosure_visual('change', 0)

command! -range EncloseDeletePrompt call enclose_text#edit_enclosure_visual('delete', 1)
command! -range EncloseChangePrompt call enclose_text#edit_enclosure_visual('change', 1)

