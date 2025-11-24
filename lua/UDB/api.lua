local cmd = {
  debug = require("UDB.cmd.launch"),
}

local M = {}

---
-- デバッグを開始するメインAPI
-- @param opts table { has_bang = boolean, label = string, ... }
function M.run_debug(opts)
  cmd.debug.start(opts)
end

return M
