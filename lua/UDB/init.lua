local unl_log = require("UNL.logging")
local udb_defaults = require("UDB.config.defaults")

local M = {}

function M.setup(user_opts)
  -- UNLのロギングセットアップ
  unl_log.setup("UDB", udb_defaults, user_opts or {})
  
  local log = unl_log.get("UDB")
  
  -- 必要であればここでDAPのアダプター設定チェックなどを行う
  -- require("UDB.dap").setup_adapters() -- 必要に応じて実装

  if log then
    log.debug("UDB.nvim setup complete.")
  end
end

return M
