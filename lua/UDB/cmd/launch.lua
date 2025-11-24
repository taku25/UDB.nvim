local unl_finder = require("UNL.finder")
local unl_picker = require("UNL.backend.picker")
local provider = require("UNL.provider")
local log = require("UDB.logger")
local fs = require("vim.fs")

local M = {}

-- ★ 変更: 安全な設定取得
local function get_config()
  local conf = require("UNL.config").get("UDB")
  -- もしUNLから設定が取れない（nil）か、中身が空っぽの場合はデフォルトを読み込む
  if not conf or vim.tbl_isempty(conf) then
    return require("UDB.config.defaults")
  end
  return conf
end

-- ★ 追加: アダプタータイプを安全に取得するヘルパー
local function get_adapter_type()
  local conf = get_config()
  if conf and conf.debugger and conf.debugger.adapter_type then
    return conf.debugger.adapter_type
  end
  return "codelldb" -- 完全なフォールバック
end

---
-- UBTプロバイダーからプリセット一覧を取得し、UDB設定とマージする
local function get_presets()
  local combined_presets = {}
  local seen_names = {}

  local conf = get_config()
  local udb_conf_presets = conf.presets or {}
  
  for _, p in ipairs(udb_conf_presets) do
    if p.name and not seen_names[p.name] then
      table.insert(combined_presets, p)
      seen_names[p.name] = true
    end
  end

  local ok, ubt_presets = provider.request("ubt.get_presets")
  if ok and ubt_presets then
    log.get().debug("Fetched %d presets from UBT provider.", #ubt_presets)
    for _, p in ipairs(ubt_presets) do
      if p.name and not seen_names[p.name] then
        table.insert(combined_presets, p)
        seen_names[p.name] = true
      end
    end
  else
    log.get().debug("Could not fetch presets from UBT provider (ok: %s).", tostring(ok))
  end

  return combined_presets
end

local function get_preset_by_name(name)
  for _, p in ipairs(get_presets()) do
    if p.name == name then return p end
  end
  return nil
end

---
-- DAP用のLaunch設定(config)を動的に生成する
local function resolve_launch_config(project_info, preset)
  if not project_info then return nil end

  local preset_name = preset and preset.name or nil

  -- 1. UBTのプロバイダー経由で Launch Config の取得を試みる (推奨)
  local ok, ubt_launch_config = provider.request("ubt.get_launch_config", { 
    preset_name = preset_name 
  })

  if ok and ubt_launch_config and ubt_launch_config.program then
    log.get().debug("Resolved launch config via UBT provider.")

    local args = ubt_launch_config.args or {}
    
    local resolved_name = ubt_launch_config.preset_name or (preset and preset.name) or "Unknown"
    
    -- ★★★ 修正箇所: ここにあった「-game」と「-log」の強制追加ロジックを削除 ★★★
    -- UBTが返した引数構成をそのまま信頼して使用します。
    -- これにより、Editor構成ならエディタが起動し、Game構成ならゲームが起動します。

    return {
      name = "UDB Launch: " .. resolved_name,
      type = get_adapter_type(), -- ★ 安全なゲッターを使用
      request = "launch",
      program = ubt_launch_config.program,
      args = args,
      cwd = ubt_launch_config.cwd or project_info.root,
      stopOnEntry = false,
      console = "integratedTerminal",
    }
  end

  -- 2. フォールバック (UBTがない場合)
  if not preset then
     log.get().warn("UBT provider failed and no preset specified. Cannot resolve launch config.")
     return nil
  end

  log.get().warn("UBT provider failed or not available. Using fallback resolution logic.")
  
  local exe_path
  local args = {}
  local cwd = project_info.root
  
  local is_windows = vim.fn.has("win32") == 1
  local ext = is_windows and ".exe" or ""

  if preset.IsEditor then
    -- Editor起動モード
    local engine_root, err = unl_finder.engine.find_engine_root(project_info.uproject)
    if not engine_root then 
      log.get().error("Engine root not found: %s", tostring(err))
      return nil 
    end

    local platform = preset.Platform or "Win64"
    local config = preset.Configuration or "Development"
    local editor_exe = "UnrealEditor" .. ext
    
    if config ~= "Development" then
      editor_exe = string.format("UnrealEditor-%s-%s%s", platform, config, ext)
    end
    
    exe_path = fs.joinpath(engine_root, "Engine", "Binaries", platform, editor_exe)
    
    table.insert(args, project_info.uproject) 
    -- フォールバックロジックでも -game は一旦外しておきます
    -- table.insert(args, "-game")
    table.insert(args, "-log")
  else
    -- Standalone
    local project_name = vim.fn.fnamemodify(project_info.uproject, ":t:r")
    local binary_name_parts = { project_name, preset.Platform }
    if preset.Configuration ~= "Development" then
      table.insert(binary_name_parts, preset.Configuration)
    end
    local binary_name = table.concat(binary_name_parts, "-") .. ext
    exe_path = fs.joinpath(project_info.root, "Binaries", preset.Platform, binary_name)
    
    table.insert(args, "-log")
  end

  return {
    name = "UDB Launch: " .. preset.name,
    type = get_adapter_type(), -- ★ 安全なゲッターを使用
    request = "launch",
    program = exe_path,
    args = args,
    cwd = cwd,
    stopOnEntry = false,
    console = "integratedTerminal", 
  }
end

---
-- nvim-dap を実行する
local function launch_dap(dap_config)
  local ok, dap = pcall(require, "dap")
  if not ok then
    log.get().error("nvim-dap is not installed!")
    return
  end

  if vim.fn.executable(dap_config.program) ~= 1 then
    log.get().error("Executable not found: %s", dap_config.program)
    return
  end

  log.get().info("Starting Debugger (Launch): %s", dap_config.program)
  dap.run(dap_config)
end

function M.start(opts)
  opts = opts or {}
  local project_info = unl_finder.project.find_from_current_buffer()
  if not project_info then
    return log.get().error("Not in an Unreal Engine project directory.")
  end

  if opts.has_bang then
    unl_picker.pick({
      kind = "udb_launch_picker",
      title = "  Select Launch Target",
      conf = get_config(),
      items = get_presets(),
      logger_name = "UDB",
      preview_enabled = false,
      entry_maker = function(item)
        return { value = item, display = item.name, ordinal = item.name }
      end,
      on_submit = function(selected_preset)
        if not selected_preset then return end
        
        local dap_conf = resolve_launch_config(project_info, selected_preset)
        if dap_conf then launch_dap(dap_conf) end
      end,
    })
  else
    local preset_to_use = nil
    if opts.label then
      preset_to_use = get_preset_by_name(opts.label)
      if not preset_to_use then
         log.get().warn("Specified preset '%s' not found.", opts.label)
         return
      end
    end

    local dap_conf = resolve_launch_config(project_info, preset_to_use)
    if dap_conf then launch_dap(dap_conf) end
  end
end

return M
