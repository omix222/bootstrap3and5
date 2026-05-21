# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## プロジェクト概要

Bootstrap 3 → 5 移行を学ぶための静的 HTML 学習ガイド。ビルドツール・npm・Node.js は一切不使用。ブラウザで HTML ファイルを直接開くだけで動作する。

## 開き方

```bash
# macOS
open index.html

# または任意のブラウザで直接開く
```

## 構成と設計方針

### ページ間の依存関係

- `index.html` — トップページ（レッスン一覧・チートシート）。Bootstrap 5 CDN のみ使用。
- `lesson*/index.html` — 各レッスン。左右2ペインで BS3 と BS5 を並べて比較する構成。
- `css/custom.css` — 全ページ共通スタイル。比較レイアウト（`.pane-bs3` / `.pane-bs5`）、コードブロック（`.code-block`）、ハイライト（`.hl-del` / `.hl-add`）を定義。

### 左ペイン（BS3）の実装方針

BS3 の CDN は**読み込まない**。BS5 の CDN と同一ページに共存するとクラスが衝突するため、BS3 の見た目は `<style>` タグ内の CSS でシミュレートする。

### 右ペイン（BS5）の実装方針

Bootstrap 5.3.3 の CDN を使用し、実際に動作するデモを提供する。JS が必要なコンポーネント（Tooltip 等）は `<script>` タグ内で手動初期化する。

### コードブロックのハイライト記法

```html
<div class="code-block"><span class="hl-del">削除されたクラス名</span>
<span class="hl-add">追加されたクラス名</span></div>
```

`white-space: pre` が効いているため、インデントと改行がそのまま表示される。

## CDN バージョン

Bootstrap 5.3.3（固定）:
- CSS: `https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css`
- JS: `https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js`

バージョンを更新する場合は全レッスンファイルの URL を一括変更すること。

## 新しいレッスンを追加するとき

1. `lesson{N}/index.html` を作成し、既存レッスンの構造（`compare-header` → 2ペイン `div[style="display:flex"]`）を踏襲する。
2. `index.html` のレッスン一覧カード（`.lesson-card`）に項目を追加する。
3. チートシートテーブルに関連する変更点の行を追加する。
