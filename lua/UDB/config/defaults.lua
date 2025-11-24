local M = {
  logging = {
    level = "info",
    echo = { level = "warn" },
    notify = { level = "error", prefix = "[UDB]" },
    file = { enable = true, max_kb = 512, rotate = 3, filename = "udb.log" },
  },
  
  -- デバッガー設定
  debugger = {
    adapter_type = "codelldb", -- デフォルトで使用するDAPアダプター
    
    -- 自動解決に失敗した場合のフォールバックなどを記述可能
  },

  -- デフォルトのターゲット設定
  presets = {
    { name = "Editor (Development)", Platform = "Win64", IsEditor = true, Configuration = "Development" },
    { name = "Editor (DebugGame)",   Platform = "Win64", IsEditor = true, Configuration = "DebugGame" },
    { name = "Game (Development)",   Platform = "Win64", IsEditor = false, Configuration = "Development" },
  },
  
  default_preset = "Editor (Development)",
}

return M
