local M = {}

-- 遅延読み込み用の変数
local unl_logging

-- UBT同様のダミーロガー
local function create_dummy_logger()
  return {
    notify = function(msg, level)
      level = level or "info"
      local lvl = vim.log.levels[(level:upper())] or vim.log.levels.INFO
      vim.notify("[UDB] " .. tostring(msg), lvl)
    end,
    info = function() end,
    warn = function() end,
    error = function() end,
    debug = function() end,
    trace = function() end,
  }
end

M.name = "UDB"

M.get = function()
  if not unl_logging then
    unl_logging = require("UNL.logging")
  end

  local logger = unl_logging.get(M.name)
  if logger then
    return logger
  end
  
  return create_dummy_logger()
end

return M
