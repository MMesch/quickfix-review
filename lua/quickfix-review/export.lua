-- Export functionality for quickfix-review.nvim
local M = {}

local utils = require('quickfix-review.utils')

-- Convert quickfix list to markdown string
function M.to_markdown(qf_list, config)
  if not qf_list or #qf_list == 0 then
    return nil, 'No comments to export'
  end

  local export_config = config.export or {}
  local header = export_config.header or ''
  local type_legend = export_config.type_legend or ''
  local item_format = export_config.item_format or '%d. [%s] %s:%d - %s'

  local lines = { header, type_legend }

  for i, item in ipairs(qf_list) do
    local file = vim.fn.fnamemodify(item.filename or vim.fn.bufname(item.bufnr), ':.')
    local comment_type = utils.parse_comment_type(item.text)
    local comment_text = item.text:gsub('^%[[^%]]*%]%s*', '')

    -- Format line reference (handle ranges)
    local line_ref
    if item.end_lnum and item.end_lnum ~= item.lnum then
      line_ref = string.format('%s:%d-%d', file, item.lnum, item.end_lnum)
    else
      line_ref = string.format('%s:%d', file, item.lnum)
    end

    -- Use custom format but replace %s:%d with our line_ref
    local line_str = string.format('%d. **[%s]** `%s` - %s', i, comment_type, line_ref, comment_text)
    table.insert(lines, line_str)
  end

  return table.concat(lines, '\n'), nil
end

-- Write content to clipboard and optionally to file
-- Returns: success (boolean), message (string)
function M.to_clipboard_and_file(content, filename)
  if not content then
    return false, 'No content to export'
  end

  -- Copy to clipboard
  vim.fn.setreg('+', content)

  -- Try to write to file
  if filename then
    local f, err = io.open(filename, 'w')
    if f then
      f:write(content)
      f:close()
      return true, string.format('Review exported to clipboard and %s', filename)
    else
      return true, 'Review copied to clipboard (could not write to file: ' .. (err or 'unknown error') .. ')'
    end
  end

  return true, 'Review copied to clipboard'
end

return M
