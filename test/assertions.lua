-- Minimal assertion library for quickfix-review tests
local M = {}

M.passed = 0
M.failed = 0
M.current_test = nil

-- Run a test with error handling
function M.run_test(name, fn)
  M.current_test = name
  local ok, err = pcall(fn)
  if ok then
    M.passed = M.passed + 1
    print(string.format('  [PASS] %s', name))
  else
    M.failed = M.failed + 1
    print(string.format('  [FAIL] %s: %s', name, err))
  end
  M.current_test = nil
end

-- Assert equality
function M.equals(actual, expected, msg)
  if actual ~= expected then
    error(string.format('%s: expected %s, got %s', msg or 'equals', tostring(expected), tostring(actual)))
  end
end

-- Assert inequality
function M.not_equals(actual, expected, msg)
  if actual == expected then
    error(string.format('%s: expected value to not equal %s', msg or 'not_equals', tostring(expected)))
  end
end

-- Assert table contains value
function M.contains(tbl, value, msg)
  if not vim.tbl_contains(tbl, value) then
    error(string.format('%s: value %s not found in table', msg or 'contains', tostring(value)))
  end
end

-- Assert string matches pattern
function M.matches(str, pattern, msg)
  if not str:match(pattern) then
    error(string.format('%s: "%s" does not match pattern "%s"', msg or 'matches', str, pattern))
  end
end

-- Assert value is truthy
function M.truthy(value, msg)
  if not value then
    error(string.format('%s: expected truthy value, got %s', msg or 'truthy', tostring(value)))
  end
end

-- Assert value is falsy
function M.falsy(value, msg)
  if value then
    error(string.format('%s: expected falsy value, got %s', msg or 'falsy', tostring(value)))
  end
end

-- Assert table length
function M.length(tbl, expected, msg)
  local actual = #tbl
  if actual ~= expected then
    error(string.format('%s: expected length %d, got %d', msg or 'length', expected, actual))
  end
end

-- Reset counters (for running multiple test files)
function M.reset()
  M.passed = 0
  M.failed = 0
end

-- Print summary and return exit code
function M.summary()
  print(string.rep('=', 50))
  local total = M.passed + M.failed
  if M.failed == 0 then
    print(string.format('All tests passed: %d/%d', M.passed, total))
  else
    print(string.format('Tests: %d passed, %d failed (total: %d)', M.passed, M.failed, total))
  end
  return M.failed
end

return M
