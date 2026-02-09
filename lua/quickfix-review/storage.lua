-- Storage functionality for quickfix-review.nvim
local M = {}

-- Save comments to file
-- Returns: success (boolean), message (string)
function M.save(qf_list, filepath)
  if not qf_list or #qf_list == 0 then
    return false, 'No comments to save'
  end

  local f, err = io.open(filepath, 'w')
  if not f then
    return false, 'Could not open file for writing: ' .. (err or 'unknown error')
  end

  local ok, encoded = pcall(vim.fn.json_encode, qf_list)
  if not ok then
    f:close()
    return false, 'Failed to encode comments as JSON'
  end

  f:write(encoded)
  f:close()

  return true, string.format('Review saved to %s (%d comments)', filepath, #qf_list)
end

-- Load comments from file
-- Returns: qf_list (table or nil), message (string)
function M.load(filepath)
  local f, err = io.open(filepath, 'r')
  if not f then
    return nil, 'No saved review found at ' .. filepath
  end

  local content = f:read('*all')
  f:close()

  if not content or content == '' then
    return nil, 'Saved review file is empty'
  end

  local ok, qf_list = pcall(vim.fn.json_decode, content)
  if not ok or not qf_list then
    return nil, 'Failed to parse saved review (invalid JSON)'
  end

  if #qf_list == 0 then
    return nil, 'No comments in saved review'
  end

  return qf_list, string.format('Review loaded: %d comments', #qf_list)
end

return M
