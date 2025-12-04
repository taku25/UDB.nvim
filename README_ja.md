# UDB.nvim

# Unreal Debugger Bridge 💓 Neovim

<img width="1222" height="817" alt="udb-debug" src="https://github.com/user-attachments/assets/c4c15d6b-0428-4fa3-bd11-272c5e93f50c" />


`UDB.nvim` は、Unreal Engine プロジェクトの C++ デバッグを Neovim 上で手軽に行うためのブリッジプラグインです。面倒な `launch.json` を手動で記述することなく、プロジェクト構造を解析して動的にデバッグ構成（Launch Config）を生成し、`nvim-dap` を介して即座にデバッグを開始できます。

これは **Unreal Neovim Plugin sweet** のデバッグ機能を担うプラグインであり、ライブラリとして [UNL.nvim](https://github.com/taku25/UNL.nvim) と[Nvim-Dap](https://github.com/mfussenegger/nvim-dap)依存しています。

[English](README.md) | [日本語 (Japanese)](README_ja.md)

-----

## ✨ 機能 (Features)

  * **ゼロ・コンフィグ デバッグ**:
      * `.uproject` ファイルの位置からエンジンのパスやバイナリの出力先を自動計算します。
      * 面倒なパス指定や引数設定（`-game`, `-log` など）を自動で行い、すぐにデバッグを開始できます。
  * **柔軟なターゲット選択**:
      * **Editor**: エディタモードで起動し、ライブコーディングやブループリントのデバッグを支援します。
      * **Game**: スタンドアローンゲームとして起動し、実際のゲームプレイ環境をデバッグします。
      * **Client / Server**: 将来的な拡張を見越した構成に対応可能です。
  * **UBT.nvim との連携 (推奨)**:
      * [UBT.nvim](https://github.com/taku25/UBT.nvim) が導入されている場合、ビルド設定から正確なプリセットを自動で取得します。
      * UBT がない場合でも、標準的な構成（Development Editorなど）へのフォールバック機能を持っています。
  * **nvim-dap インテグレーション**:
      * Neovim のデファクトスタンダードである [nvim-dap](https://github.com/mfussenegger/nvim-dap) をラップし、Unreal Engine に特化した起動フローを提供します。
      * `codelldb` などの主要な DAP アダプターに対応しています。

## 🔧 必要要件 (Requirements)

  * Neovim v0.11.3 以上
  * [**UNL.nvim**](https://github.com/taku25/UNL.nvim) (**必須**)
  * [**nvim-dap**](https://github.com/mfussenegger/nvim-dap) (**必須**)
  * **デバッガーアダプターサンプル:**
      * C++ デバッグのために `codelldb` (推奨) または `cpptools` のセットアップが必要です。
      * [mason.nvim](https://github.com/williamboman/mason.nvim) および [mason-nvim-dap.nvim](https://github.com/jay-babu/mason-nvim-dap.nvim) の利用を強く推奨します。
      * **設定サンプル (codelldb):**
        ```lua
        dap.adapters.codelldb = {
          type = 'server',
          port = "${port}",
          executable = {
            command = vim.fn.stdpath("data") .. "/mason/bin/codelldb.cmd",
            args = {"--port", "${port}"},
            detached = false,
          }
        }
        ```

## 🚀 インストール (Installation)

お好みのプラグインマネージャーでインストールしてください。

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
return {
  'taku25/UDB.nvim',
  dependencies = {
     'taku25/UNL.nvim',
     'mfussenegger/nvim-dap',
     -- オプション: UI体験向上のために推奨
     'rcarriga/nvim-dap-ui', 
  },
  opts = {
    -- UDB固有の設定があればここに記述します
  },
}
```

## ⚙️ 設定 (Configuration)

このプラグインは、ライブラリである `UNL.nvim` のセットアップ関数を通じて設定されますが、`UDB.nvim` に直接 `opts` を渡すことも可能です。

以下は `UDB.nvim` のデフォルト設定です。

```lua
opts = {
  logging = {
    level = "info",
    -- その他のログ設定はUNL準拠
  },
  
  -- デバッガー設定
  debugger = {
    -- デフォルトで使用するDAPアダプター名
    -- mason-nvim-dapなどでインストールしたアダプター名を指定してください
    adapter_type = "codelldb", 
  },

  -- デフォルトのターゲット設定（UBT連携が利用できない場合のフォールバック）
  presets = {
    { name = "Editor (Development)", Platform = "Win64", IsEditor = true, Configuration = "Development" },
    { name = "Editor (DebugGame)",   Platform = "Win64", IsEditor = true, Configuration = "DebugGame" },
    { name = "Game (Development)",   Platform = "Win64", IsEditor = false, Configuration = "Development" },
  },
  
  default_preset = "Editor (Development)",
}
```

## ⚡ 使い方 (Usage)

すべてのコマンドは `:UDB` から始まります。

```viml
" デフォルト（または前回選択した）ターゲットでデバッグを開始します
:UDB run_debug

" ターゲット（Editor/Game/Configuration）を選択してデバッグを開始します
:UDB run_debug!
```

### コマンド詳細

  * **`:UDB run_debug[!]`**:

      * 引数なしで実行すると、設定された `default_preset` または前回使用した構成で即座にデバッガーを起動します。
      * 現在開いているファイルが Unreal Engine プロジェクト内にあることを自動検出し、そのプロジェクトのルートを基準に動作します。
  Bang付き
      * 起動ターゲットを選択するためのピッカー UI を開きます。
      * リストには `UBT.nvim` から取得した動的なプリセット、または `Config` で定義されたフォールバックプリセットが表示されます。
      * 例:
          * `Editor (Development)`: エディタを起動 (UnrealEditor.exe ProjectName ...)
          * `Game (Development)`: ゲームを起動 (ProjectName.exe ...)

## 🤖 API & 自動化 (Automation Examples)

`UDB.api` モジュールを使用して、キーマップをカスタマイズできます。

### キーマップ作成例

F5 キーでデバッグ開始、Shift+F5 でターゲット選択といった、Visual Studio ライクな操作性を実現できます。

```lua
local udb = require("UDB.api")

-- F5: デバッグ開始 (前回の設定またはデフォルト)
vim.keymap.set('n', '<F5>', function() 
  udb.run_debug({ has_bang = false }) 
end, { desc = "UDB: Start Debugging" })

-- Shift+F5: ターゲットを選択してデバッグ開始
vim.keymap.set('n', '<S-F5>', function() 
  udb.run_debug({ has_bang = true }) 
end, { desc = "UDB: Select Target & Debug" })
```

## その他

Unreal Engine 関連プラグイン:

  * [**UnrealDev.nvim**](https://github.com/taku25/UnrealDev.nvim)
      * **推奨:** これら全てのUnreal Engine関連プラグインを一括で導入・管理できるオールインワンスイートです。
  * [**UNX.nvim**](https://github.com/taku25/UNX.nvim)
      * **標準搭載:** Unreal Engine開発に特化した専用のエクスプローラー＆サイドバーです。Neo-tree等に依存せず、プロジェクト構造、クラス概形、プロファイリング結果などを表示できます。
  * [UEP.nvim](https://github.com/taku25/UEP.nvim)
      * .uprojectを解析してファイルナビゲートなどを簡単に行えるようになります。
  * [UEA.nvim](https://github.com/taku25/UEA.nvim)
      * C++クラスがどのBlueprintアセットから使用されているかを検索します。
  * [UBT.nvim](https://github.com/taku25/UBT.nvim)
      * BuildやGenerateClangDataBaseなどを非同期でNeovim上から使えるようになります。
  * [UCM.nvim](https://github.com/taku25/UCM.nvim)
      * クラスの追加や削除がNeovim上からできるようになります。
  * [ULG.nvim](https://github.com/taku25/ULG.nvim)
      * UEのログやLiveCoding, stat fpsなどをNeovim上から操作できるようになります。
  * [USH.nvim](https://github.com/taku25/USH.nvim)
      * ushellをNeovimから対話的に操作できるようになります。
  * [USX.nvim](https://github.com/taku25/USX.nvim)
      * tree-sitter-unreal-cpp や tree-sitter-unreal-shader のハイライト設定などを補助するプラグインです。
  * [neo-tree-unl](https://github.com/taku25/neo-tree-unl.nvim)
      * もし [neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim) をお使いの場合は、こちらを使うことでIDEのようなプロジェクトエクスプローラーを表示できます。
  * [tree-sitter for Unreal Engine](https://github.com/taku25/tree-sitter-unreal-cpp)
      * UCLASSなどを含めてtree-sitterの構文木を使ってハイライトができます。
  * [tree-sitter for Unreal Engine Shader](https://github.com/taku25/tree-sitter-unreal-shader)
      * .usfや.ushなどのUnreal Shader用のシンタックスハイライトを提供します。

## 📜 ライセンス (License)

MIT License

Copyright (c) 2025 taku25

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
