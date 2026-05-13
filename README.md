# KAME-MAPPER

A Lisp-style interactive command mapper for macOS. Define your own commands in S-expressions and launch apps, open URLs, run scripts, and more from a single REPL.

> This project is under active development.

## Overview

KAME-MAPPER is a personal command launcher built with [Racket](https://racket-lang.org/). It provides an interactive REPL where you type S-expressions to execute commands. You can extend it by adding `.sexp` files to define your own shortcuts.

```
🐢 (app chrome)
🐢 (app list)
🐢 (+ 1 2 3)
6
🐢 (exit)
```

## Requirements

- [Racket](https://racket-lang.org/) (v9.1+)
- [rlwrap](https://github.com/hanslub42/rlwrap) (for readline support)
- macOS

## Usage

### Run

```sh
make run
```

### Build & Distribute

```sh
make build   # Compile to executable
make dist    # Create distributable bundle (includes sexp/ and lib/)
make all     # Clean, build, and distribute
```

### Test

```sh
make test
```

## Built-in Functions

### Shell Commands

| Command | Description |
|---------|-------------|
| `(open "path")` | Open a file or folder |
| `(open -a "App Name")` | Open an application |
| `(open -a "App Name" "url")` | Open a URL in a specific app |
| `(system "command")` | Execute a shell command |
| `(pbcopy "text")` | Copy text to clipboard |

### Reserved Functions

- Arithmetic: `+`, `-`, `*`, `/`, `=`, `>`, `<`
- List: `list`, `car`, `cdr`, `cons`
- I/O: `displayln`, `newline`
- Control: `begin`
- Conversion: `exact->inexact`

### REPL Commands

| Command | Description |
|---------|-------------|
| `(help)` | Show help |
| `(version)` | Show version |
| `(exit)` | Quit |

## Extensions

Extensions are `.sexp` files placed in the `sexp/` directory. Each file defines a set of named commands.

### File Format

```scheme
(
  (subcommand1 . ((command . (open -a "App Name"))
                  (note . "Description")))
  (subcommand2 . ((command . (system "echo hello"))
                  (note . "Another command")))
)
```

### Invocation

| Pattern | Behavior |
|---------|----------|
| `(filename)` | Run the file as a single command |
| `(filename subcommand)` | Run a specific subcommand |
| `(filename list)` or `(filename ?)` | List all subcommands |

### Example

Create `sexp/mytools.sexp`:

```scheme
(
  (editor . ((command . (open -a "Visual Studio Code"))
             (note . "VS Code")))
  (terminal . ((command . (open -a "Terminal"))
               (note . "Terminal")))
)
```

Then use it:

```
🐢 (mytools editor)    ;; Opens VS Code
🐢 (mytools list)      ;; Lists all subcommands
```

## Custom Scripts

Place shell scripts in the `lib/` directory and call them via extensions using `(system "./lib/your-script.sh")`.

## License

N/A

---

# KAME-MAPPER (日本語)

macOS向けのLispスタイルのインタラクティブコマンドマッパー。S式で独自のコマンドを定義し、REPLからアプリの起動、URL表示、スクリプト実行などを行えます。

> このプロジェクトは開発中です。

## 概要

KAME-MAPPERは[Racket](https://racket-lang.org/)で構築されたパーソナルコマンドランチャーです。S式を入力してコマンドを実行するインタラクティブREPLを提供します。`sexp/`ディレクトリに`.sexp`ファイルを追加して自由に拡張できます。

```
🐢 (app chrome)
🐢 (app list)
🐢 (+ 1 2 3)
6
🐢 (exit)
```

## 必要なもの

- [Racket](https://racket-lang.org/) (v9.1以上)
- [rlwrap](https://github.com/hanslub42/rlwrap) (readline対応)
- macOS

## 使い方

### 実行

```sh
make run
```

### ビルド・配布

```sh
make build   # 実行ファイルにコンパイル
make dist    # 配布用バンドル作成（sexp/とlib/を含む）
make all     # クリーン、ビルド、配布を一括実行
```

### テスト

```sh
make test
```

## 組み込み機能

### シェルコマンド

| コマンド | 説明 |
|---------|------|
| `(open "パス")` | ファイルやフォルダを開く |
| `(open -a "アプリ名")` | アプリケーションを起動 |
| `(open -a "アプリ名" "URL")` | 指定アプリでURLを開く |
| `(system "コマンド")` | シェルコマンドを実行 |
| `(pbcopy "テキスト")` | クリップボードにコピー |

### 予約関数

- 算術: `+`, `-`, `*`, `/`, `=`, `>`, `<`
- リスト: `list`, `car`, `cdr`, `cons`
- 入出力: `displayln`, `newline`
- 制御: `begin`
- 変換: `exact->inexact`

### REPLコマンド

| コマンド | 説明 |
|---------|------|
| `(help)` | ヘルプを表示 |
| `(version)` | バージョンを表示 |
| `(exit)` | 終了 |

## 拡張コマンド

拡張コマンドは`sexp/`ディレクトリに配置する`.sexp`ファイルで定義します。各ファイルにはサブコマンドのセットを記述します。

### ファイル形式

```scheme
(
  (サブコマンド1 . ((command . (open -a "アプリ名"))
                   (note . "説明")))
  (サブコマンド2 . ((command . (system "echo hello"))
                   (note . "別のコマンド")))
)
```

### 呼び出し方

| パターン | 動作 |
|---------|------|
| `(ファイル名)` | ファイル全体を単一コマンドとして実行 |
| `(ファイル名 サブコマンド)` | 特定のサブコマンドを実行 |
| `(ファイル名 list)` または `(ファイル名 ?)` | サブコマンド一覧を表示 |

### 例

`sexp/mytools.sexp`を作成:

```scheme
(
  (editor . ((command . (open -a "Visual Studio Code"))
             (note . "VS Code")))
  (terminal . ((command . (open -a "Terminal"))
               (note . "ターミナル")))
)
```

使い方:

```
🐢 (mytools editor)    ;; VS Codeを起動
🐢 (mytools list)      ;; サブコマンド一覧を表示
```

## カスタムスクリプト

`lib/`ディレクトリにシェルスクリプトを配置し、拡張コマンドから`(system "./lib/your-script.sh")`で呼び出せます。
