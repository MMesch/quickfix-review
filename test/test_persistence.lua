-- Tests for save/load functionality
local test_helper = dofile('test/init.lua')
local assert = dofile('test/assertions.lua')

print('\nRunning persistence tests...')

local qf = test_helper.setup_test_environment()
local test_file = test_helper.create_test_file([[
line 1
line 2
line 3
line 4
line 5
]])

local test_storage_file = 'test_review_storage.json'

-- Override storage file for testing
local config = require('quickfix-review.config')
config.options.storage_file = test_storage_file

local function cleanup_storage()
  os.remove(test_storage_file)
end

assert.run_test('save empty review', function()
  cleanup_storage()
  vim.fn.setqflist({})

  qf.save_review()
  -- Should not error, just print message
  assert.truthy(true, 'save completed')
end)

assert.run_test('save and load single comment', function()
  cleanup_storage()
  vim.fn.setqflist({})
  vim.fn.cursor(3, 1)
  qf.add_comment('ISSUE')
  assert.length(vim.fn.getqflist(), 1, 'comment added')

  qf.save_review()

  -- Clear and reload
  vim.fn.setqflist({})
  assert.length(vim.fn.getqflist(), 0, 'quickfix cleared')

  qf.load_review()

  local list = vim.fn.getqflist()
  assert.length(list, 1, 'comment loaded')
  assert.equals(list[1].lnum, 3, 'correct line number')
  assert.matches(list[1].text, '%[ISSUE%]', 'correct comment type')
end)

assert.run_test('save and load multiline comment', function()
  cleanup_storage()
  vim.fn.setqflist({})
  qf.add_comment('NOTE', { 2, 4 })
  assert.length(vim.fn.getqflist(), 1, 'multiline comment added')

  local original = vim.fn.getqflist()[1]

  qf.save_review()
  vim.fn.setqflist({})
  qf.load_review()

  local list = vim.fn.getqflist()
  assert.length(list, 1, 'comment loaded')
  assert.equals(list[1].lnum, original.lnum, 'start line preserved')
  assert.equals(list[1].end_lnum, original.end_lnum, 'end line preserved')
end)

assert.run_test('save and load multiple comments', function()
  cleanup_storage()
  vim.fn.setqflist({})

  vim.fn.cursor(1, 1)
  qf.add_comment('ISSUE')
  vim.fn.cursor(3, 1)
  qf.add_comment('SUGGESTION')
  qf.add_comment('NOTE', { 4, 5 })
  assert.length(vim.fn.getqflist(), 3, 'three comments added')

  qf.save_review()
  vim.fn.setqflist({})
  qf.load_review()

  local list = vim.fn.getqflist()
  assert.length(list, 3, 'all comments loaded')
end)

assert.run_test('load from non-existent file', function()
  cleanup_storage()
  vim.fn.setqflist({})

  -- This should not error, just print a message
  qf.load_review()
  assert.length(vim.fn.getqflist(), 0, 'quickfix still empty')
end)

assert.run_test('save overwrites previous save', function()
  cleanup_storage()
  vim.fn.setqflist({})

  vim.fn.cursor(1, 1)
  qf.add_comment('ISSUE')
  vim.fn.cursor(2, 1)
  qf.add_comment('ISSUE')
  qf.save_review()

  vim.fn.setqflist({})
  vim.fn.cursor(5, 1)
  qf.add_comment('NOTE')
  qf.save_review()

  vim.fn.setqflist({})
  qf.load_review()

  local list = vim.fn.getqflist()
  assert.length(list, 1, 'only latest save loaded')
  assert.matches(list[1].text, '%[NOTE%]', 'correct comment from latest save')
end)

-- Final cleanup
cleanup_storage()
test_helper.cleanup_test_environment()

return assert
