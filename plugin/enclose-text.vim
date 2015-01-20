
command! -range EncloseAppend call enclose_text#edit_enclosure('append', 0)
command! -range EncloseDelete call enclose_text#edit_enclosure('delete', 0)
command! -range EncloseChange call enclose_text#edit_enclosure('change', 0)

command! -range EncloseDeletePrompt call enclose_text#edit_enclosure('delete', 1)
command! -range EncloseChangePrompt call enclose_text#edit_enclosure('change', 1)

