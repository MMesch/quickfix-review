-- Auto-load file for quickfix-review.nvim
-- Defines user commands

if vim.g.loaded_quickfix_review then
  return
end
vim.g.loaded_quickfix_review = 1

-- Create user commands
vim.api.nvim_create_user_command('ReviewAddIssue', function()
  require('quickfix-review').add_comment('ISSUE')
end, { desc = 'Add an ISSUE comment at current line' })

vim.api.nvim_create_user_command('ReviewAddSuggestion', function()
  require('quickfix-review').add_comment('SUGGESTION')
end, { desc = 'Add a SUGGESTION comment at current line' })

vim.api.nvim_create_user_command('ReviewAddNote', function()
  require('quickfix-review').add_comment('NOTE')
end, { desc = 'Add a NOTE comment at current line' })

vim.api.nvim_create_user_command('ReviewAddPraise', function()
  require('quickfix-review').add_comment('PRAISE')
end, { desc = 'Add a PRAISE comment at current line' })

vim.api.nvim_create_user_command('ReviewExport', function()
  require('quickfix-review').export_review()
end, { desc = 'Export review to markdown and clipboard' })

vim.api.nvim_create_user_command('ReviewClear', function()
  require('quickfix-review').clear_review()
end, { desc = 'Clear all review comments' })

vim.api.nvim_create_user_command('ReviewSave', function()
  require('quickfix-review').save_review()
end, { desc = 'Save review to disk' })

vim.api.nvim_create_user_command('ReviewLoad', function()
  require('quickfix-review').load_review()
end, { desc = 'Load review from disk' })

vim.api.nvim_create_user_command('ReviewSummary', function()
  require('quickfix-review').summary()
end, { desc = 'Show review summary' })

vim.api.nvim_create_user_command('ReviewGoto', function()
  require('quickfix-review').goto_real_file()
end, { desc = 'Go to real file from diff buffer' })

vim.api.nvim_create_user_command('ReviewView', function()
  require('quickfix-review').view_comment()
end, { desc = 'View comment on current line' })

vim.api.nvim_create_user_command('ReviewDelete', function()
  require('quickfix-review').delete_comment()
end, { desc = 'Delete comment at current line' })
