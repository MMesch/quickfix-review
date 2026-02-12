-- Utility functions for quickfix-review.nvim
local M = {}
local config = require('quickfix-review.config')

-- Namespace for extmarks (lazy initialized)
local ns_id = nil

-- Get or create the namespace ID
function M.get_ns_id()
  if not ns_id then
    ns_id = vim.api.nvim_create_namespace('quickfix_review')
  end
  return ns_id
end

-- Store sign configuration for extmark use
M.sign_config = {}

-- Get comment types dynamically from configuration
function M.get_comment_types()
  return vim.tbl_keys(config.options.comment_types)
end

-- Get configuration for a specific comment type
function M.get_comment_type_config(type_name)
  return config.options.comment_types[type_name:lower()]
end

-- Priority map for sign stacking (lower than git signs which typically use 6-10)
-- Generated dynamically based on comment types
function M.get_sign_priority(type_name)
  -- Base priority based on type importance
  local type_config = M.get_comment_type_config(type_name)
  if not type_config then return 50 end
  
  -- Map highlight groups to priorities
  local priority_map = {
    DiagnosticError = 5,
    DiagnosticWarn = 4,
    DiagnosticInfo = 3,
    DiagnosticHint = 2
  }
  
  local base_priority = priority_map[type_config.highlight] or 3
  
  -- Continuation signs get lower priority
  if type_name:find('_continuation$') then
    return 1
  end
  
  return base_priority
end

-- Initialize signs based on configuration
function M.init_signs(config)
  local signs = config.signs or {}
  for type_name, sign_def in pairs(signs) do
    vim.fn.sign_define('review_' .. type_name, sign_def)
    M.sign_config[type_name] = sign_def
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

-- Place signs for a comment using extmarks (supports multiple signs per line)
function M.place_comment_signs(bufnr, comment_type, start_line, end_line)
  if bufnr <= 0 or vim.fn.bufexists(bufnr) ~= 1 then return end

  local type_key = comment_type:lower()
  local sign_cfg = M.sign_config[type_key]
  local cont_cfg = M.sign_config[type_key .. '_continuation']

  if not sign_cfg then return end

  local priority = M.get_sign_priority(type_key) or 50

  -- Place sign at start line using extmark
  vim.api.nvim_buf_set_extmark(bufnr, M.get_ns_id(), start_line - 1, 0, {
    sign_text = sign_cfg.text,
    sign_hl_group = sign_cfg.texthl,
    priority = priority,
  })

  if start_line ~= end_line and cont_cfg then
    local cont_priority = M.get_sign_priority(type_key .. '_continuation') or 30
    for line = start_line + 1, end_line - 1 do
      vim.api.nvim_buf_set_extmark(bufnr, M.get_ns_id(), line - 1, 0, {
        sign_text = cont_cfg.text,
        sign_hl_group = cont_cfg.texthl,
        priority = cont_priority,
      })
    end
    -- Place sign at end line
    vim.api.nvim_buf_set_extmark(bufnr, M.get_ns_id(), end_line - 1, 0, {
      sign_text = sign_cfg.text,
      sign_hl_group = sign_cfg.texthl,
      priority = priority,
    })
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
