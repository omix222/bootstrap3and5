# Bootstrap 3 → 5 移行学習ガイド

Bootstrap 3 から Bootstrap 5 への移行を **左右比較形式** で学べる静的 HTML 学習リソースです。
npm・Node.js・ビルドツールは一切不要。ブラウザでファイルを直接開くだけで動作します。

---

## 特徴

- **左右2ペイン比較** — 同じ UI を BS3 と BS5 で並べて表示
- **実際に動くデモ** — モーダル・Toast・Carousel・Offcanvas など右ペインで動作確認できる
- **差分ハイライト** — 削除コードを赤（`.hl-del`）、追加コードを緑（`.hl-add`）でハイライト
- **BS3 CDN 不使用** — 左ペインは CSS でシミュレートし、クラス衝突を回避
- **ビルド不要** — HTML ファイルをブラウザに直接ドロップして開くだけ

---

## 使い方

```bash
git clone <このリポジトリのURL>
cd bootstrap
open index.html        # macOS
# Windows / Linux: エクスプローラーから index.html をブラウザにドロップ
```

---

## ファイル構成

```
bootstrap/
├── index.html          # トップ（レッスン一覧 + チートシート）
├── css/custom.css      # 全ページ共通スタイル
├── lesson1/index.html  # グリッドシステム
├── lesson2/index.html  # ナビゲーションバー
├── lesson3/index.html  # カード
├── lesson4/index.html  # フォーム
├── lesson5/index.html  # JavaScript / jQuery 不要化
├── lesson6/index.html  # ユーティリティクラス（RTL 対応）
└── lesson7/index.html  # コンポーネント刷新
```

---

## レッスン詳細

### Lesson 1 — グリッドシステム

**Float ベース → Flexbox ベースに刷新。ブレークポイントも xs 廃止・xxl 追加。**

| 項目 | Bootstrap 3 | Bootstrap 5 |
|---|---|---|
| グリッド基盤 | Float | Flexbox |
| 最小 BP | `col-xs-*` | `col-*`（xs なし） |
| 最大 BP | `lg` | `xxl`（≥1400px）追加 |
| オフセット | `col-md-offset-4` | `offset-md-4` |
| Gutter | なし | `g-*` / `gx-*` / `gy-*` |
| 自動均等分割 | なし | `col`（数値なし） |
| 行あたり列数 | なし | `row-cols-*` |
| 並び順制御 | `col-md-push-*` / `col-md-pull-*` | `order-*` / `order-md-first` / `order-md-last` |
| 縦方向整列 | なし | `align-items-*` / `align-self-*` |
| 横方向整列 | なし | `justify-content-*` |
| 表示・非表示 | `visible-*` / `hidden-*` | `d-none` / `d-{bp}-block` 等 |
| container 種類 | `container` / `container-fluid` の2択 | `container-{sm\|md\|lg\|xl\|xxl\|fluid}` |

**ブレークポイント対照表：**

| 名称 | BS3 | BS5 | 幅 |
|---|---|---|---|
| — | `col-xs-*` | `col-*` | &lt; 576px |
| sm | `col-sm-*` | `col-sm-*` | ≥ 576px |
| md | `col-md-*` | `col-md-*` | ≥ 768px |
| lg | `col-lg-*` | `col-lg-*` | ≥ 992px |
| xl | なし | `col-xl-*` | ≥ 1200px |
| xxl | なし | `col-xxl-*` | ≥ 1400px（新規）|

```html
<!-- BS3 -->
<div class="col-xs-12 col-md-6">
<div class="col-md-4 col-md-offset-4">
<div class="col-md-4 col-md-push-8">  <!-- 並び順 -->

<!-- BS5 -->
<div class="col-12 col-md-6">
<div class="col-md-4 offset-md-4">
<div class="col order-3">             <!-- 並び順 -->

<!-- BS5 新機能 -->
<div class="row row-cols-2 row-cols-md-4 g-3">  <!-- 行あたり列数 + Gutter -->
<div class="row align-items-center justify-content-between">  <!-- Flexbox 整列 -->
```

---

### Lesson 2 — ナビゲーションバー

**`data-toggle` → `data-bs-toggle`。カラーは bg-* ユーティリティで自由指定。Offcanvas が新登場。**

| 項目 | Bootstrap 3 | Bootstrap 5 |
|---|---|---|
| カラースキーム | `navbar-default` / `navbar-inverse` の2択 | `navbar-light` / `navbar-dark` + `bg-*` |
| トグル属性 | `data-toggle="collapse"` | `data-bs-toggle="collapse"` |
| ターゲット属性 | `data-target="#id"` | `data-bs-target="#id"` |
| ハンバーガー | `navbar-header` + `icon-bar` ×3 | `navbar-toggler` + `navbar-toggler-icon` |
| リンク構造 | `<li><a>` | `<li class="nav-item"><a class="nav-link">` |
| レスポンシブ制御 | `navbar-collapse` のみ | `navbar-expand-{sm\|md\|lg\|xl\|xxl}` |
| 検索フォーム | `navbar-form navbar-left` | `d-flex` でラップ |
| ドロップダウン区切り | `<li role="separator" class="divider">` | `<hr class="dropdown-divider">` |
| ドロップダウン項目 | `<li><a>` | `<a class="dropdown-item">` |
| 固定ナビバー | `navbar-fixed-top` / `navbar-static-top` | `fixed-top` / `sticky-top` |
| タブ/ピル active | `<li class="active">` | `<button class="nav-link active">` |
| Offcanvas | なし | `offcanvas offcanvas-start` など（新機能）|

```html
<!-- BS3 -->
<nav class="navbar navbar-default">
  <div class="navbar-header">
    <button class="navbar-toggle" data-toggle="collapse" data-target="#nav">
      <span class="icon-bar"></span>×3
    </button>
  </div>
  <ul class="nav navbar-nav"><li class="active"><a>ホーム</a></li></ul>
</nav>

<!-- BS5 -->
<nav class="navbar navbar-expand-lg navbar-light bg-light">
  <button class="navbar-toggler" data-bs-toggle="collapse" data-bs-target="#nav">
    <span class="navbar-toggler-icon"></span>
  </button>
  <ul class="navbar-nav"><li class="nav-item"><a class="nav-link active">ホーム</a></li></ul>
</nav>
```

---

### Lesson 3 — カード（panel / well / thumbnail → card）

**BS3 の3種類のコンテナ系コンポーネントがすべて `card` に統合された。**

| BS3 | 用途 | BS5 代替 |
|---|---|---|
| `panel panel-default` | タイトル・本文・フッター付き枠 | `card` + `card-header/body/footer` |
| `panel-primary` 等 | カラーバリアント | `card text-bg-primary` 等 |
| `well` | グレー背景のインセット枠 | `card bg-light` |
| `well-sm` / `well-lg` | サイズ違い well | `p-2` / `p-4` で代替 |
| `thumbnail` | 画像 + キャプション | `card` + `card-img-top` + `card-body` |
| `caption` | thumbnail 内テキスト | `card-body` + `card-title` / `card-text` |
| `card-group` | ボーダーなし隣接 | `row g-0` |
| `card-deck` | 等高・等幅並び | `row g-3` + `h-100` |

**BS5 新機能：**
- `row-cols-*` で行あたりの列数を自動制御
- `card-img-overlay` で画像上にテキストオーバーレイ
- 水平カード（`row g-0` + `img-fluid rounded-start`）
- `list-group-flush` でカード内にリストグループをシームレスに組み込み

```html
<!-- BS3: panel -->
<div class="panel panel-default">
  <div class="panel-heading">タイトル</div>
  <div class="panel-body">本文</div>
  <div class="panel-footer">フッター</div>
</div>

<!-- BS5: card -->
<div class="card">
  <div class="card-header">タイトル</div>
  <div class="card-body">本文</div>
  <div class="card-footer text-muted">フッター</div>
</div>

<!-- BS5: カードグリッド（新機能） -->
<div class="row row-cols-1 row-cols-md-3 g-3">
  <div class="col"><div class="card h-100">...</div></div>
</div>
```

---

### Lesson 4 — フォーム

**`form-group` 廃止・バリデーション付与先が親 → input 本体に変更・多数の新機能追加。**

| 項目 | Bootstrap 3 | Bootstrap 5 |
|---|---|---|
| フィールドラッパー | `form-group` | `mb-3`（廃止・スペーシングで代替）|
| ラベル | `<label>` | `<label class="form-label">` |
| 補足テキスト | `<span class="help-block">` | `<div class="form-text">` |
| エラー状態 | 親に `has-error` | input に `is-invalid` |
| 成功状態 | 親に `has-success` | input に `is-valid` |
| フィードバック文 | `help-block` | `invalid-feedback` / `valid-feedback` |
| チェックボックス | `<div class="checkbox"><label>` | `<div class="form-check">` |
| ラジオ | `<div class="radio"><label>` | `<div class="form-check">` （同じクラス）|
| スイッチ | `custom-control custom-switch` | `form-check form-switch` |
| Range | `custom-range` | `form-range` |
| ファイル入力 | `custom-file` + `custom-file-input` | `form-control type="file"` |
| セレクト | `form-control` | `form-select` |
| インラインフォーム | `form-inline` | `row g-3 align-items-end` + `col-auto`（廃止）|
| Input Group 前置 | `input-group-addon` | `input-group-text` |
| Input Group 後置ボタン | `input-group-btn` | button を直接並べる |
| input サイズ | `input-lg` / `input-sm` | `form-control-lg` / `form-control-sm` |
| select サイズ | — | `form-select-lg` / `form-select-sm` |
| フローティングラベル | なし | `form-floating`（新機能）|

```html
<!-- BS3 -->
<div class="form-group has-error">
  <label>メール</label>
  <input class="form-control">
  <span class="help-block">エラー</span>
</div>
<div class="custom-file">
  <input type="file" class="custom-file-input">
  <label class="custom-file-label">選択</label>
</div>
<input type="range" class="custom-range">

<!-- BS5 -->
<div class="mb-3">
  <label class="form-label">メール</label>
  <input class="form-control is-invalid">
  <div class="invalid-feedback">エラー</div>
</div>
<input class="form-control" type="file">
<input type="range" class="form-range">

<!-- BS5 新機能：フローティングラベル（placeholder 必須）-->
<div class="form-floating mb-3">
  <input type="email" class="form-control" id="mail" placeholder="dummy">
  <label for="mail">メールアドレス</label>
</div>
```

---

### Lesson 5 — JavaScript / jQuery 不要化

**BS5 最大の変更。jQuery ゼロ。`data-bs-*` に統一。Toast / Offcanvas / Carousel が刷新。**

| 項目 | Bootstrap 3 | Bootstrap 5 |
|---|---|---|
| 依存ライブラリ | jQuery 必須 | Vanilla JS のみ |
| JS ファイル | `jquery.min.js` + `bootstrap.min.js` | `bootstrap.bundle.min.js` 1つのみ |
| `data-toggle` | `data-toggle` | `data-bs-toggle` |
| `data-target` | `data-target` | `data-bs-target` |
| `data-dismiss` | `data-dismiss` | `data-bs-dismiss` |
| `data-parent` | `data-parent` | `data-bs-parent` |
| `data-ride` | `data-ride` | `data-bs-ride` |
| `data-slide` | `data-slide` | `data-bs-slide` |
| `data-slide-to` | `data-slide-to` | `data-bs-slide-to` |
| 閉じるボタン | `<button class="close"><span>&times;</span></button>` | `<button class="btn-close">` |
| 開いた状態 | `collapse in` | `collapse show` |
| アコーディオン | `panel-group` + `panel-default` | `accordion` + `accordion-item` |
| モーダル JS API | `$('#m').modal('show')` | `new bootstrap.Modal('#m').show()` |
| インスタンス取得 | — | `bootstrap.Modal.getInstance('#m')` |
| Toast | なし | `toast` / `toast-container`（新機能）|
| Offcanvas | なし | `offcanvas offcanvas-{start\|end\|top\|bottom}`（新機能）|
| Carousel コントロール | Glyphicons アイコン使用 | `carousel-control-prev-icon` / `carousel-control-next-icon` |

```js
// BS3: jQuery プラグイン
$('#myModal').modal('show')
$('[data-toggle="tooltip"]').tooltip()

// BS5: Vanilla JS クラス
new bootstrap.Modal('#myModal').show()
document.querySelectorAll('[data-bs-toggle="tooltip"]')
  .forEach(el => new bootstrap.Tooltip(el))

// イベントリスナー
document.querySelector('#myModal')
  .addEventListener('shown.bs.modal', () => { ... })
```

---

### Lesson 6 — ユーティリティクラスの変更（RTL 対応）

**BS5 は RTL（右から左）言語に対応するため、方向を含むクラス名が left/right → start/end に統一された。**

| 変更前（BS3） | 変更後（BS5） | 意味 |
|---|---|---|
| `ml-*` | `ms-*` | margin-left（margin-start）|
| `mr-*` | `me-*` | margin-right（margin-end）|
| `pl-*` | `ps-*` | padding-left（padding-start）|
| `pr-*` | `pe-*` | padding-right（padding-end）|
| `text-left` | `text-start` | 左揃え |
| `text-right` | `text-end` | 右揃え |
| `text-md-right` | `text-md-end` | レスポンシブ版も同様 |
| `pull-left` | `float-start` | 左に float |
| `pull-right` | `float-end` | 右に float |
| `border-left` | `border-start` | 左ボーダー |
| `border-right` | `border-end` | 右ボーダー |
| `rounded-left` | `rounded-start` | 左丸角 |
| `rounded-right` | `rounded-end` | 右丸角 |
| `sr-only` | `visually-hidden` | スクリーンリーダー専用 |
| `show` / `hide` | `d-block` / `d-none` | 表示・非表示 |
| `embed-responsive embed-responsive-16by9` | `ratio ratio-16x9` | レスポンシブ埋め込み |
| `btn-block` | `d-grid`（廃止）| 全幅ボタン |
| `close` + `&times;` | `btn-close` | 閉じるボタン |
| `text-bg-*` | — | 背景+文字色セット（BS5.3 新機能）|

```html
<!-- BS3 -->
<div class="ml-3 mr-3 pl-2 pr-2">
<div class="text-right">
<div class="pull-right">
<button class="btn btn-primary btn-block">全幅</button>
<button class="close"><span>&times;</span></button>

<!-- BS5 -->
<div class="ms-3 me-3 ps-2 pe-2">
<div class="text-end">
<div class="float-end">
<div class="d-grid"><button class="btn btn-primary">全幅</button></div>
<button class="btn-close"></button>

<!-- ratio（embed-responsive 代替） -->
<div class="ratio ratio-16x9">
  <iframe src="..."></iframe>
</div>
<!-- ratio-1x1 / ratio-4x3 / ratio-16x9 / ratio-21x9 -->
```

---

### Lesson 7 — コンポーネント刷新

**badge と label の統合、Spinner / Placeholder の新登場、Alert / Progress の細かい変更。**

| 項目 | Bootstrap 3 | Bootstrap 5 |
|---|---|---|
| Badge（数値） | `<span class="badge">` | `<span class="badge bg-primary">` |
| Label（テキスト） | `<span class="label label-primary">` | `<span class="badge bg-primary">`（統合）|
| ピル型 | `label-pill` | `badge rounded-pill` |
| Alert 閉じる | `class="close"` + `data-dismiss="alert"` | `class="btn-close"` + `data-bs-dismiss="alert"` |
| Alert アニメ | 手動 | `fade show` クラスで自動 |
| Button btn-xs | あり | 廃止 |
| Button btn-block | あり | `d-grid` で代替（廃止）|
| Progress 色 | `progress-bar` のみ | `progress-bar bg-success` 等 |
| Progress ストライプ | `progress-bar-striped progress-bar-animated` | 変更なし |
| Progress aria | 自前管理 | `aria-label` 推奨 |
| List Group バッジ | `<span class="badge">` | `<span class="badge rounded-pill bg-primary">` |
| List Group リンク | `list-group-item` のみ | `list-group-item list-group-item-action` |
| List Group カラー | — | `list-group-item-success` 等 |
| Breadcrumb active | `<li class="active">` | `<li aria-current="page">` |
| Spinner | なし | `spinner-border` / `spinner-grow`（新機能）|
| Placeholder | なし | `placeholder` + `placeholder-glow`（新機能）|

```html
<!-- BS3: badge と label が別 -->
<span class="badge">4</span>
<span class="label label-primary">Primary</span>
<span class="label label-pill">ピル</span>

<!-- BS5: badge に統合 -->
<span class="badge bg-secondary">4</span>
<span class="badge bg-primary">Primary</span>
<span class="badge rounded-pill bg-primary">ピル</span>

<!-- BS5 新機能: Spinner -->
<div class="spinner-border text-primary"></div>   <!-- 回転型 -->
<div class="spinner-grow text-success"></div>     <!-- 拡大型 -->
<div class="spinner-border spinner-border-sm"></div>  <!-- 小サイズ -->

<!-- BS5 新機能: Placeholder（スケルトン UI） -->
<div class="placeholder-glow">
  <span class="placeholder col-6"></span>
  <span class="placeholder col-4"></span>
</div>
```

---

## 全変更点チートシート

### クラス名の変更一覧

| カテゴリ | Bootstrap 3 | Bootstrap 5 |
|---|---|---|
| **グリッド** | `col-xs-*` | `col-*` |
| | `col-md-offset-4` | `offset-md-4` |
| | `col-md-push-*` / `col-md-pull-*` | `order-*` |
| | `visible-*` / `hidden-*` | `d-{bp}-{value}` |
| | — | `col`（Auto-layout）|
| | — | `g-*` / `gx-*` / `gy-*`（Gutter）|
| | — | `row-cols-*`（行あたり列数）|
| | — | `align-items-*` / `justify-content-*` |
| | — | `container-{sm/md/lg/xl/xxl}` |
| **ナビバー** | `navbar-default` | `navbar-light bg-light` |
| | `navbar-inverse` | `navbar-dark bg-dark` |
| | `navbar-toggle` / `icon-bar` | `navbar-toggler` / `navbar-toggler-icon` |
| | `navbar-header` | 廃止 |
| | `nav navbar-nav` → `<li><a>` | `navbar-nav` → `nav-item` + `nav-link` |
| | `navbar-fixed-top` | `fixed-top` |
| | `navbar-form navbar-left` | `d-flex` |
| **カード** | `panel panel-default` | `card` |
| | `panel-heading/body/footer` | `card-header/body/footer` |
| | `panel-primary` 等 | `text-bg-primary` 等 |
| | `well` / `well-sm` / `well-lg` | `card bg-light` + `p-*` |
| | `thumbnail` / `caption` | `card` + `card-img-top` + `card-body` |
| | `card-group` / `card-deck` | `row g-0` / `row g-3 + h-100` |
| **フォーム** | `form-group` | `mb-3` |
| | `help-block` | `form-text` |
| | `has-error` / `has-success`（親） | `is-invalid` / `is-valid`（input）|
| | `checkbox` / `radio` | `form-check` |
| | `custom-range` | `form-range` |
| | `custom-control custom-switch` | `form-check form-switch` |
| | `custom-file` + `custom-file-input` | `form-control type="file"` |
| | `form-control`（select） | `form-select` |
| | `input-group-addon` | `input-group-text` |
| | `input-group-btn` | 直接 button を配置 |
| | `input-lg` / `input-sm` | `form-control-lg` / `form-control-sm` |
| | `form-inline` | `row col-auto`（廃止）|
| | — | `form-floating`（新機能）|
| **JS 属性** | `data-toggle` | `data-bs-toggle` |
| | `data-target` | `data-bs-target` |
| | `data-dismiss` | `data-bs-dismiss` |
| | `data-parent` | `data-bs-parent` |
| | `data-ride` | `data-bs-ride` |
| | `data-slide-to` | `data-bs-slide-to` |
| | `collapse in` | `collapse show` |
| **ユーティリティ** | `ml-*` / `mr-*` | `ms-*` / `me-*` |
| | `pl-*` / `pr-*` | `ps-*` / `pe-*` |
| | `text-left` / `text-right` | `text-start` / `text-end` |
| | `pull-left` / `pull-right` | `float-start` / `float-end` |
| | `border-left` / `border-right` | `border-start` / `border-end` |
| | `rounded-left` / `rounded-right` | `rounded-start` / `rounded-end` |
| | `sr-only` | `visually-hidden` |
| | `show` / `hide` | `d-block` / `d-none` |
| | `embed-responsive embed-responsive-16by9` | `ratio ratio-16x9` |
| | `btn-block` | `d-grid`（廃止）|
| | `btn-xs` | 廃止 |
| **コンポーネント** | `badge`（数値） + `label`（テキスト） | `badge bg-*` に統合 |
| | `label-pill` | `badge rounded-pill` |
| | `close` + `<span>&times;</span>` | `btn-close` |
| | `panel-group` + `panel-default`（アコーディオン） | `accordion` + `accordion-item` |
| | — | `spinner-border` / `spinner-grow`（新機能）|
| | — | `toast` / `toast-container`（新機能）|
| | — | `offcanvas offcanvas-start` 等（新機能）|
| | — | `placeholder` + `placeholder-glow`（新機能）|

### その他の主要変更

| 項目 | Bootstrap 3 | Bootstrap 5 |
|---|---|---|
| jQuery | 必須 | 不要（Vanilla JS）|
| グリッド基盤 | Float | Flexbox |
| Popper.js | 別途読み込み | bundle に内包済み |
| RTL サポート | なし | `dir="rtl"` で有効 |
| CSS カスタムプロパティ | なし | `--bs-primary` 等 |
| ダークモード | なし | `data-bs-theme="dark"` |
| Glyphicons | 内包 | 廃止（Bootstrap Icons 等を別途使用）|

---

## 使用 CDN バージョン

Bootstrap **5.3.3** 固定

```
CSS: https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css
JS:  https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js
```

---

## 新しいレッスンを追加するには

1. `lesson{N}/index.html` を作成し、既存レッスンの構造を踏襲する

```
compare-header（ブレッドクラム付き）
└── display:flex の2ペインコンテナ
    ├── .pane.pane-bs3（左：BS3、CSS シミュレート）
    └── .pane.pane-bs5（右：BS5、CDN 使用・実動作）
```

2. `index.html` の `.lesson-card` 一覧に項目を追加する
3. `index.html` のチートシートテーブルに関連行を追加する
4. このREADMEの「レッスン詳細」と「全変更点チートシート」を更新する
