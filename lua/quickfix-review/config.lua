-- Configuration and defaults for quickfix-review.nvim
local M = {}

-- Default configuration
M.defaults = {
  -- Storage file path for saving/loading reviews
  storage_file = vim.fn.stdpath('data') .. '/quickfix-review.json',

  -- Default export filename (nil = clipboard only, set to 'quickfix-review.md' to also save to file)
  export_file = nil,

  -- Prompt to clear comments when file changes on disk
  prompt_on_file_change = false,

  -- Comment type definitions (can be extended by users)
  comment_types = {
    issue = { sign = '⚠', highlight = 'DiagnosticError', description = 'Problems to fix' },
    suggestion = { sign = '💭', highlight = 'DiagnosticWarn', description = 'Improvements' },
    note = { sign = '📝', highlight = 'DiagnosticInfo', description = 'Observations' },
    praise = { sign = '✨', highlight = 'DiagnosticHint', description = 'Positive feedback' },
    question = { sign = '?', highlight = 'DiagnosticInfo', description = 'Clarification needed' },
    insight = { sign = '💡', highlight = 'DiagnosticHint', description = 'Useful observations' }
  },

  -- Sign definitions (generated from comment_types, but can be overridden)
  signs = {},

  -- Export format strings
  export = {
    header = '# Code Review\n\n',
    type_legend = '',  -- Generated dynamically from comment_types
    item_format = '%d. **[%s]** `%s:%d` - %s',
  },

  -- Keymaps (set to false to disable a keymap)
  keymaps = {
    add_issue = '<leader>ci',
    add_suggestion = '<leader>cs',
    add_note = '<leader>cn',
    add_praise = '<leader>cp',
    add_question = '<leader>cq',
    add_insight = '<leader>ck',
    
    -- Comment type cycling
    add_comment_cycle = '<leader>ca',  -- Add comment with current cycle type
    cycle_next = '+',                  -- Cycle to next type
    cycle_previous = '-',              -- Cycle to previous type
    
    delete_comment = '<leader>cd',
    export = '<leader>ce',
    clear = '<leader>cc',
    summary = '<leader>cS',
    save = '<leader>cw',
    load = '<leader>cr',
    open_list = '<leader>co',
    next_comment = ']r',
    prev_comment = '[r',
    goto_real_file = '<leader>cg',
    view = '<leader>cv',
  },
}

-- Current options (populated by setup)
M.options = {}

-- Setup configuration by merging user options with defaults
function M.setup(opts)
  local user_opts = opts or {}
  
  -- Start with defaults and then merge user options on top
  M.options = vim.tbl_deep_extend('force', {}, M.defaults, user_opts)
  
  -- Generate signs from comment_types if not explicitly overridden
  if not user_opts.signs or vim.tbl_isempty(user_opts.signs) then
    M.options.signs = {}
    
    -- Generate main signs and continuation signs from comment_types
    for type_name, type_config in pairs(M.options.comment_types) do
      -- Main sign
      M.options.signs[type_name] = {
        text = type_config.sign,
        texthl = type_config.highlight
      }
      
      -- Continuation sign
      local cont_key = type_name .. '_continuation'
      M.options.signs[cont_key] = {
        text = '│',
        texthl = type_config.highlight
      }
    end
  end
  
  -- Generate type legend for export
  local type_descriptions = {}
  for type_name, type_config in pairs(M.options.comment_types) do
    table.insert(type_descriptions, type_name:upper() .. ' (' .. type_config.description .. ')')
  end
  M.options.export.type_legend = 'Comment types: ' .. table.concat(type_descriptions, ', ') .. '\n'

  return M
end
return M
