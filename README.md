Fork of https://github.com/tzachar/highlight-undo.nvim

> [!NOTE]
> You may not need this, if you don't need highlight on every change:
> `:h vim.hl.hl_op()`

Minor changes
* Never re-attach on the same buffer.
* Fix a bug when change then undo too quickly.
* Use `BufEnter` autocmd only.
* Require neovim 0.11
  * https://github.com/neovim/neovim/issues/32012.
  * https://github.com/neovim/neovim/pull/33283.
* Workaround empty chunk (https://github.com/vim/vim/issues/17410).
