-- Utility functions for quickfix-review.nvim
local M = {}

local COMMENT_TYPES = {'issue', 'suggestion', 'note', 'praise'}

-- Initialize signs based on configuration
function M.init_signs(config)
  local signs = config.signs or {}
  for _, t in ipairs(COMMENT_TYPES) do
    if signs[t] then
      vim.fn.sign_define('review_' .. t, signs[t])
    end
    local cont_key = t .. '_continuation'
    if signs[cont_key] then
      vim.fn.sign_define('review_' .. cont_key, signs[cont_key])
    end
  end
end

-- Check if two file paths refer to the same file
function M.files_match(file1, file2)
  if file1 == file2 then return true end
  local abs1 = vim.fn.fnamemodify(file1, ':p')
  local abs2 = vim.fn.fnamemodify(file2, ':p')
  return abs1 == abs2
end

-- Extract comment type from formatted text like "[ISSUE]" or "[ISSUE:L1-5]"
function M.parse_comment_type(text)
  return text:match('%[([^:%]]+)') or 'NOTE'
end

-- Place signs for a comment (handles both single and multiline)
function M.place_comment_signs(bufnr, comment_type, start_line, end_line)
  if bufnr <= 0 or vim.fn.bufexists(bufnr) ~= 1 then return end

  local sign_name = 'review_' .. comment_type:lower()
  local cont_sign = sign_name .. '_continuation'

  vim.fn.sign_place(0, 'review', sign_name, bufnr, { lnum = start_line })

  if start_line ~= end_line then
    for line = start_line + 1, end_line - 1 do
      vim.fn.sign_place(0, 'review', cont_sign, bufnr, { lnum = line })
    end
    vim.fn.sign_place(0, 'review', sign_name, bufnr, { lnum = end_line })
  end
end

-- Extract real file path from special diff buffers
function M.get_real_filepath()
  local bufname = vim.fn.expand('%:p')

  -- Handle diffview buffers: diffview:///path/.git//hash/file.txt
  local diffview_match = bufname:match('diffview://.*//[^/]+/(.*)')
  if diffview_match then
    return diffview_match
  end

  -- Handle fugitive buffers: fugitive:///path/.git//hash/file.txt
  local fugitive_match = bufname:match('fugitive://.*//[^/]+/(.*)')
  if fugitive_match then
    return fugitive_match
  end

  -- Handle codediff buffers
  local codediff_match = bufname:match('codediff://+(.+)')
  if codediff_match then
    local clean_path = codediff_match:match('//:[^/]+/(.*)')
    if clean_path then
      return clean_path
    end
    clean_path = codediff_match:match('/+([^/].*)')
    if clean_path then
      return clean_path
    end
  end

  return bufname
end

-- Check if current buffer is a diff/special buffer
function M.is_special_buffer()
  local bufname = vim.fn.expand('%:p')
  return bufname:match('^diffview://')
      or bufname:match('^fugitive://')
      or bufname:match('^codediff://')
end

return M
