---START INJECT hlc.lua

local api = vim.api

---@class hlc.bufstate
---@field timer uv.uv_timer_t?
---@field cancel fun()? range_clear A function which allows clearing the highlight manually.

---@type table<integer, hlc.bufstate?>
local bufstates = {}

local ignored_ft = { mason = true, lazy = true }
local opts = {
  timeout = 150,
  hlgroup = 'DiffAdded',
  ignore = function(buf)
    local bo = vim.bo[buf]
    return bo.buftype ~= '' and not bo.modifiable or ignored_ft[bo.ft]
  end,
}

local ns_id = api.nvim_create_namespace('u.hlc')

local function on_bytes(_, bufnr, _, start_row, start_col, _, _, _, _, new_end_row, new_end_col, _)
  if opts.ignore(bufnr) then return true end -- e.g. ft is set defered...
  if api.nvim_get_mode().mode:match('i') then return end
  local bufstate = assert(bufstates[bufnr])
  local num_lines = api.nvim_buf_line_count(0)
  local end_row = start_row + new_end_row
  local end_col = start_col + new_end_col
  if end_row >= num_lines then end_col = #api.nvim_buf_get_lines(0, -2, -1, false)[1] end
  vim.schedule(function()
    if bufstate.cancel then bufstate.cancel() end
    bufstate.timer, bufstate.cancel = vim.hl.range(
      bufnr,
      ns_id,
      opts.hlgroup,
      { start_row, start_col },
      { end_row, end_col },
      { timeout = opts.timeout }
    )
  end)
end

local function on_detach(_, buf)
  local bufstate = assert(bufstates[buf])
  if bufstate.timer then uv.timer_stop(bufstate.timer) end
  bufstates[buf] = nil
end

local function attach(buf)
  if bufstates[buf] or opts.ignore(buf) then return end
  bufstates[buf] = {}
  api.nvim_buf_attach(buf, false, { on_bytes = on_bytes, on_detach = on_detach })
end

local M = {}

function M.enable()
  api.nvim_create_autocmd({ 'BufEnter' }, {
    pattern = '*',
    callback = function(ev) attach(ev.buf) end,
  })
end

return M
