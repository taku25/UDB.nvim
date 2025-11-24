if vim.g.loaded_udb then
  return
end
vim.g.loaded_udb = true

-- requireを安全に実行
local function safe_require(name)
  local ok, mod = pcall(require, name)
  if not ok then
    vim.notify("UDB.nvim: !!! FATAL ERROR! require('" .. name .. "') failed!", vim.log.levels.ERROR)
    return nil
  end
  return mod
end

local builder = safe_require("UNL.command.builder")
if not builder then return end

local udb_api = safe_require("UDB.api")
if not udb_api then return end

local log = safe_require("UDB.logger")
if not log then return end

-- UNLのコマンドビルダーを使って :UDB コマンドを作成
builder.create({
  plugin_name = "UDB",
  cmd_name = "UDB",
  desc = "UDB: Unreal Debugger commands",
  subcommands = {
    ["run_debug"] = {
      handler = function(opts) udb_api.run_debug(opts) end,
      desc = "Start debugging with nvim-dap. Use 'run_debug!' to select target.",
      bang = true, -- !をつけるとピッカーが開くようにする
      args = {
        { name = "label", required = false },
      },
    },
    -- 将来的にブレークポイント管理などをここに追加可能
  },
})
