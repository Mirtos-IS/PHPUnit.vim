# phpunit.vim
This is a fork os c9s/phpunit.vim. 

![phpunit.vim](https://pbs.twimg.com/media/CPwwG-4UcAA-KXs.png:large)


## Install via Vundle

```vim
Plugin "Mirtos-IS/phpunit.vim"
```

## Install via Vim-Plug
```vim
Plug "Mirtos-IS/phpunit.vim"
```vim

## Configurations

Use full path
```vim
" the directory that contains your phpunit test cases.
let g:phpunit_test_root = 'tests'
```

```vim
" the directory that contains source files.
let g:phpunit_src_root = 'src'
```

```vim
" the location of your phpunit file.
let g:phpunit_bin = 'phpunit'
```

```vim
" php unit command line options
let g:phpunit_options = ["--stop-on-failure"]
```

## Key Mappings

- `<leader>ta` - Run all test cases
- `<leader>ts` - Switch between source & test file
- `<leader>tf` - Run current test case class
- `<leader>tc` - Close test file
## License

MIT License
