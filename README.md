Fork of https://github.com/tzachar/highlight-undo.nvim

Minor changes
* Never re-attach on the same buffer.
* Fix a bug when change then undo too quickly.
* Use `BufEnter` autocmd only.
* Require https://github.com/neovim/neovim/issues/32012.
