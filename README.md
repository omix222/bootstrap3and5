# Bootstrap 3 → 5 移行学習ガイド

Bootstrap 3 から 5 への移行を、左右比較形式で学べる静的 HTML 学習リソースです。
npm・Node.js 不要で、ブラウザでファイルを直接開くだけで動作します。

## 使い方

```bash
# リポジトリをクローン
git clone <このリポジトリのURL>
cd bootstrap

# ブラウザで開く（macOS）
open index.html
```

またはエクスプローラー / Finder から `index.html` をブラウザにドラッグ＆ドロップしてください。

## レッスン一覧

| # | テーマ | 主な変更点 |
|---|---|---|
| 1 | グリッドシステム | `col-xs-*` 廃止 → `col-*`、`xxl` ブレークポイント追加、Auto-layout |
| 2 | ナビゲーションバー | `data-toggle` → `data-bs-toggle`、`navbar-default` 廃止 |
| 3 | カード | `panel` / `well` / `thumbnail` がすべて `card` に統合 |
| 4 | フォーム | `form-group` 廃止 → `mb-3`、フローティングラベル新登場 |
| 5 | JavaScript / jQuery 不要化 | `data-bs-*` 属性、Vanilla JS API、Tooltip 初期化 |

## Bootstrap 3 → 5 主要変更点チートシート

| カテゴリ | Bootstrap 3 | Bootstrap 5 |
|---|---|---|
| 最小ブレークポイント | `col-xs-*` | `col-*` |
| JS トグル属性 | `data-toggle` | `data-bs-toggle` |
| JS ターゲット属性 | `data-target` | `data-bs-target` |
| JS 閉じる属性 | `data-dismiss` | `data-bs-dismiss` |
| 依存ライブラリ | jQuery 必須 | Vanilla JS のみ |
| パネル系 | `panel` / `well` / `thumbnail` | `card` |
| フォームグループ | `form-group` | `mb-3`（廃止） |
| バリデーション状態 | 親に `has-error` / `has-success` | input に `is-invalid` / `is-valid` |
| ナビバー色 | `navbar-default` / `navbar-inverse` | `navbar-light` / `navbar-dark` + `bg-*` |
| 最大ブレークポイント | `lg` まで | `xxl`（≥1400px）追加 |
| グリッド基盤 | Float | Flexbox |
| Gutter 指定 | なし | `g-*` ユーティリティ |
| RTL サポート | なし | あり |

## 画面構成

各レッスンページは左右2ペイン構成です。

```
┌─────────────────────┬─────────────────────┐
│  Bootstrap 3（左）   │  Bootstrap 5（右）   │
│  CSS でシミュレート   │  実際に動作するデモ  │
│  hl-del で削除を表示 │  hl-add で追加を表示 │
└─────────────────────┴─────────────────────┘
```

左ペインは Bootstrap 3 の CDN を読み込まず CSS で見た目を再現しています（BS5 CDN とのクラス競合を防ぐため）。
