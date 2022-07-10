highlight PHPUnitFail guibg=Red ctermbg=Red guifg=White ctermfg=White
highlight PHPUnitOK guibg=Green ctermbg=Green guifg=Black ctermfg=Black
highlight PHPUnitAssertFail guifg=LightRed ctermfg=LightRed

" root of unit tests
if !exists('g:phpunit_test_root')
  let g:phpunit_test_root = 'tests'
endif
if !exists('g:phpunit_src_root')
  let g:phpunit_project_root = '.'
endif

if !exists('g:php_bin')
  let g:php_bin = ''
endif

if !exists('g:phpunit_bin')
  let g:phpunit_bin = 'phpunit'
endif

if !exists('g:phpunit_options')
  let g:phpunit_options = ['--colors', '--stop-on-failure', '--columns=50']
endif

" you can set there subset of tests if you do not want to run
" full set
if !exists('g:phpunit_tests')
  let g:phpunit_tests = g:phpunit_test_root
endif


let g:PHPUnit = {}

fun! g:PHPUnit.buildBaseCommand()
  let cmd = []
  if g:php_bin != ""
    call add(cmd, g:php_bin)
  endif
  call add(cmd, g:phpunit_bin)
  call add(cmd, join(g:phpunit_options, " "))
  return cmd
endfun

fun! g:PHPUnit.Run(cmd, title)
  redraw
  echohl Title
  echomsg "* Running PHP Unit test(s) [" . a:title . "] *"
  echohl None
  redraw
  echomsg "* Done PHP Unit test(s) [" . a:title . "] *"
  echohl None
  let output = system(join(a:cmd," "))
  silent call g:PHPUnit.OpenBuffer(output)
endfun

fun! g:PHPUnit.OpenBuffer(content)
  " is there phpunit_buffer?
  if exists('g:phpunit_buffer') && bufexists(g:phpunit_buffer)
    let phpunit_win = bufwinnr(g:phpunit_buffer)
    " is buffer visible?
    if phpunit_win > 0
      " switch to visible phpunit buffer
      execute phpunit_win . "wincmd w"
    else
      " split current buffer, with phpunit_buffer
      execute "rightbelow vertical sb ".g:phpunit_buffer
    endif
    " well, phpunit_buffer is opened, clear content
    setlocal modifiable
    silent %d
  else
    " there is no phpunit_buffer create new one
    rightbelow vnew
    let g:phpunit_buffer=bufnr('%')
  endif

  file PHPUnit
  " exec 'file Diff-' . file
  setlocal nobuflisted cursorline nonumber buftype=nofile filetype=phpunit modifiable bufhidden=hide
  setlocal noswapfile
  silent put=a:content
  "efm=%E%\\d%\\+)\ %m,%CFailed%m,%Z%f:%l,%-G
  " FIXME: It is better use match(), or :syntax

  call matchadd("PHPUnitFail","^FAILURES.*$")
  call matchadd("PHPUnitOK","^OK .*$")

  call matchadd("PHPUnitFail","^not ok .*$")
  call matchadd("PHPUnitOK","^ok .*$")

  call matchadd("PHPUnitAssertFail","^Failed asserting.*$")
  setlocal nomodifiable

  wincmd p
endfun




fun! g:PHPUnit.RunAll()
  let cmd = g:PHPUnit.buildBaseCommand()
  let cmd = cmd + [expand(g:phpunit_test_root)]

  silent call g:PHPUnit.Run(cmd, "RunAll")
endfun

fun! g:PHPUnit.RunCurrentFile()
  let cmd = g:PHPUnit.buildBaseCommand()
  let file = g:GetRightFile(0)
  let cmd = cmd +  [file]
  silent call g:PHPUnit.Run(cmd, file)
endfun
fun! g:PHPUnit.RunTestCase(filter)
  let cmd = g:PHPUnit.buildBaseCommand()
  let cmd = cmd + ["--filter", a:filter , bufname("%:p")]
  silent call g:PHPUnit.Run(cmd, bufname("%:p") . ":" . a:filter)
endfun

fun! g:PHPUnit.SwitchFile()
  let file = g:GetRightFile()
  " check if there's a window with that file open. -1 if not
  let win = bufwinnr(file)
  if win > 0
    execute win . "wincmd w"
  else
    execute "vsplit " . file
    " create a directory for the file
    let dir = expand('%:p:h')
    if ! isdirectory(dir)
      cal mkdir(dir,'p')
    endif
  endif
endf

fun! g:PHPUnit.CloseTestFile()
    let file = g:GetRightFile(0)
    let isTest = expand('%:t') =~ "Test\.php$"
    " check for windows with 
    let win = bufwinnr(file)
    if win > 0 && !isTest
        execute win . "wincmd c"
    endif
    let phpunit = bufwinnr(g:phpunit_buffer)
    if phpunit > 0
        execute phpunit . "wincmd c"
    endif
endf

    "returns my test file full path if 0
    "full path reverse file (original <-> test) if 1
fun! g:GetRightFile(test = 1)
    "Allow to set full dir with ~/ or $HOME
  let test_dir = expand(g:phpunit_test_root)
  let src_dir = expand(g:phpunit_src_root)
    "get file name
  let file = expand('%:p')
    "compare to see if is a test or not using regex(0 to false, 1 to true)
  let isTest = expand('%:t') =~ "Test\.php$"

  if isTest && a:test
    " replace phpunit_test_root with libroot
  let file = substitute(file, test_dir, src_dir, '')

    " remove 'Test.' from filename
  let file = substitute(file,'Test\.php$','.php','')
  else
    " get the file name with no .php + full path
    let file = expand('%:p:r')
    " change the src directory with test directory (if ~/your_directory/src/project, it just take
    " the src off and replace by test ~/your_directory/tests/project)
    let file = substitute(file, src_dir, test_dir , '')
    if !isTest
        let file = file . 'Test.php'
    else
        let file = file . '.php'
    endif
  endif
  return file
endf

command! -nargs=0 PHPUnitRunAll :call g:PHPUnit.RunAll()
command! -nargs=0 PHPUnitRunCurrentFile :call g:PHPUnit.RunCurrentFile()
command! -nargs=1 PHPUnitRunFilter :call g:PHPUnit.RunTestCase(<f-args>)
command! -nargs=0 PHPUnitSwitchFile :call g:PHPUnit.SwitchFile()
command! -nargs=0 PHPUnitClose :call g:PHPUnit.CloseTestFile()

nnoremap <silent><Leader>ta :PHPUnitRunAll<CR>
nnoremap <silent><Leader>tf :PHPUnitRunCurrentFile<CR>
nnoremap <silent><Leader>ts :PHPUnitSwitchFile<CR>
nnoremap <silent><leader>tc :PHPUnitClose<CR>
