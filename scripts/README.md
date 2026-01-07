## Scripts Referenced by Various Config Files

- Manually copy over to `~/.local/bin/` on every fresh install

To use `~/.local/bin`, you might need to add it to your `$PATH` in your `.zshrc` file:
```
path=("$HOME/.local/bin" $path)
typeset -U path
```
Then make sure everything has correct permission:
`chmod +x ~/.local/bin/*`

