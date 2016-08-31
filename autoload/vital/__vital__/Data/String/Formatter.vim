let s:t_string = type('')
let s:t_number = type(0)
let s:t_list = type([])
let s:t_dict = type({})
let s:t_funcref = type(function('tr'))

" format rule:
"   %{<left>|<right>}<key>
"     '<left><value><right>' if <value> != ''
"     ''                     if <value> == ''
"   %{<left>}<key>
"     '<left><value>'        if <value> != ''
"     ''                     if <value> == ''
"   %{|<right>}<key>
"     '<value><right>'       if <value> != ''
"     ''                     if <value> == ''
function! s:format(format, format_map, data) abort
  if empty(a:data)
    return ''
  endif
  let pattern_base = '\C%\%({\([^|}]*\)\%(|\([^}]*\)\)\?}\)\?'
  let str = copy(a:format)
  for [key, Value] in items(a:format_map)
    let pattern = pattern_base . key
    if str =~# pattern
      if type(Value) == s:t_funcref
        let result = s:_smart_string(call(Value, [a:data], a:format_map))
      else
        let result = s:_smart_string(get(a:data, Value, ''))
      endif
      let repl = strlen(result) ? '\1' . escape(result, '\') . '\2' : ''
      let str = substitute(str, pattern, repl, 'g')
    endif
    unlet! Value
  endfor
  return substitute(str, '^\s\+\|\s\+$', '', 'g')
endfunction

function! s:_smart_string(value) abort
  let t_value = type(a:value)
  if t_value == s:t_string
    return a:value
  elseif t_value == s:t_number
    return a:value ? string(a:value) : ''
  elseif t_value == s:t_list || t_value == s:t_dict
    return !empty(a:value) ? string(a:value) : ''
  else
    return string(a:value)
  endif
endfunction
