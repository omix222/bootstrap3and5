# Bootstrap 3 → 5 移行学習ガイド

Bootstrap 3 から Bootstrap 5 への移行を **左右比較形式** で学べる静的 HTML 学習リソースです。
npm・Node.js・ビルドツールは一切不要。ブラウザでファイルを直接開くだけで動作します。

---

## 特徴

- **左右2ペイン比較** — 同じ UI を BS3 と BS5 で並べて表示
- **実際に動くデモ** — モーダル・アコーディオン・Tooltip など右ペインで動作確認できる
- **差分ハイライト** — 削除されたコードを赤、追加されたコードを緑でハイライト
- **BS3 CDN 不使用** — 左ペインは CSS でシミュレートし、クラス衝突を回避
- **完全オフライン不可**（CDN 参照あり）/ **ビルド不要**（HTML ファイルをそのまま開く）

---

## 使い方

```bash
# リポジトリをクローン
git clone <このリポジトリのURL>
cd bootstrap

# ブラウザで開く（macOS）
open index.html

# Windows / Linux はエクスプローラー / ファイルマネージャーから index.html をブラウザにドロップ
```

`index.html` がトップページです。各レッスンへのリンクとチートシートが掲載されています。

---

## ファイル構成

```
bootstrap/
├── index.html          # トップ（レッスン一覧 + チートシート）
├── css/
│   └── custom.css      # 全ページ共通スタイル（比較レイアウト・コードハイライト）
├── lesson1/
│   └── index.html      # グリッドシステム
├── lesson2/
│   └── index.html      # ナビゲーションバー
├── lesson3/
│   └── index.html      # カード（panel / well / thumbnail）
├── lesson4/
│   └── index.html      # フォーム
└── lesson5/
    └── index.html      # JavaScript / jQuery 不要化
```

---

## レッスン詳細

### Lesson 1 — グリッドシステム

**グリッドの基盤が Float → Flexbox に刷新。**
ブレークポイントも再設計され `xs` が廃止、`xxl` が追加された。

| 項目 | Bootstrap 3 | Bootstrap 5 |
|---|---|---|
| グリッド基盤 | Float | Flexbox |
| 最小ブレークポイント | `col-xs-*` | `col-*`（xs なし） |
| 最大ブレークポイント | `col-lg-*` | `col-xxl-*`（xxl 追加） |
| オフセット | `col-md-offset-4` | `offset-md-4` |
| 列間スペース（gutter） | なし（padding で代用） | `g-*` / `gx-*` / `gy-*` |
| 自動均等分割 | なし | `col`（数値なし）で均等 |

**ブレークポイント対照表：**

| 名称 | BS3 | BS5 | 幅 |
|---|---|---|---|
| — | `col-xs-*` | `col-*` | &lt; 576px |
| sm | `col-sm-*` | `col-sm-*` | ≥ 576px |
| md | `col-md-*` | `col-md-*` | ≥ 768px |
| lg | `col-lg-*` | `col-lg-*` | ≥ 992px |
| xl | なし | `col-xl-*` | ≥ 1200px |
| xxl | なし | `col-xxl-*` | ≥ 1400px（新規追加） |

**主な書き換え例：**

```html
<!-- BS3 -->
<div class="col-xs-12 col-md-6">...</div>
<div class="col-md-4 col-md-offset-4">...</div>

<!-- BS5 -->
<div class="col-12 col-md-6">...</div>
<div class="col-md-4 offset-md-4">...</div>
```

```html
<!-- BS5 新機能：Auto-layout（幅を省略すると均等分割） -->
<div class="row">
  <div class="col">自動</div>
  <div class="col">自動</div>
  <div class="col-6">固定6</div>
</div>

<!-- BS5 新機能：Gutter -->
<div class="row g-3">...</div>   <!-- 縦横両方 -->
<div class="row gx-3">...</div>  <!-- 横のみ -->
<div class="row gy-3">...</div>  <!-- 縦のみ -->
```

---

### Lesson 2 — ナビゲーションバー

**jQuery 依存の `data-toggle` / `data-target` が `data-bs-*` に統一。**
カラースキームも `navbar-default` / `navbar-inverse` の2択から `bg-*` ユーティリティで自由指定に。

| 項目 | Bootstrap 3 | Bootstrap 5 |
|---|---|---|
| カラースキーム | `navbar-default`（灰）/ `navbar-inverse`（黒）のみ | `navbar-light` / `navbar-dark` + `bg-*` で自由指定 |
| トグル属性 | `data-toggle="collapse"` | `data-bs-toggle="collapse"` |
| ターゲット属性 | `data-target="#id"` | `data-bs-target="#id"` |
| ハンバーガー構造 | `navbar-header` + `icon-bar` ×3 | `navbar-toggler` + `navbar-toggler-icon` |
| リンク構造 | `<li><a>` | `<li class="nav-item"><a class="nav-link">` |
| レスポンシブ制御 | `navbar-collapse` で一律 | `navbar-expand-{sm|md|lg|xl|xxl}` で BP 指定 |
| ドロップダウン区切り | `<li role="separator">` | `<hr class="dropdown-divider">` |

**主な書き換え例：**

```html
<!-- BS3 -->
<nav class="navbar navbar-default">
  <div class="navbar-header">
    <button class="navbar-toggle" data-toggle="collapse" data-target="#nav">
      <span class="icon-bar"></span>
      <span class="icon-bar"></span>
      <span class="icon-bar"></span>
    </button>
  </div>
  <div class="collapse navbar-collapse" id="nav">
    <ul class="nav navbar-nav">
      <li class="active"><a href="#">ホーム</a></li>
    </ul>
  </div>
</nav>

<!-- BS5 -->
<nav class="navbar navbar-expand-lg navbar-light bg-light">
  <div class="container-fluid">
    <a class="navbar-brand" href="#">Brand</a>
    <button class="navbar-toggler" type="button"
            data-bs-toggle="collapse" data-bs-target="#nav">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="nav">
      <ul class="navbar-nav">
        <li class="nav-item">
          <a class="nav-link active" href="#">ホーム</a>
        </li>
      </ul>
    </div>
  </div>
</nav>
```

```html
<!-- BS5 ナビバーカラー例 -->
<nav class="navbar navbar-dark bg-dark">...</nav>
<nav class="navbar navbar-dark bg-primary">...</nav>
<nav class="navbar navbar-light bg-warning">...</nav>
```

---

### Lesson 3 — カード（panel / well / thumbnail → card）

**BS3 にあった3種類のコンテナ系コンポーネントがすべて `card` に統合された。**

| BS3 コンポーネント | 用途 | BS5 での代替 |
|---|---|---|
| `panel` | タイトル・本文・フッター付きコンテナ | `card` + `card-header/body/footer` |
| `panel-primary` 等 | パネルのカラーバリエーション | `card text-bg-primary` 等 |
| `well` | インセット枠（グレー背景） | `card bg-light` |
| `well-sm` / `well-lg` | サイズ違いの well | `p-2` / `p-4` ユーティリティで代替 |
| `thumbnail` | 画像 + キャプションのカード | `card` + `card-img-top` + `card-body` |
| `caption` | thumbnail 内のテキストエリア | `card-body` + `card-title` / `card-text` |

**主な書き換え例：**

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
```

```html
<!-- BS3: thumbnail -->
<div class="thumbnail">
  <img src="img.jpg" alt="...">
  <div class="caption">
    <h3>タイトル</h3>
    <p>説明</p>
  </div>
</div>

<!-- BS5: card -->
<div class="card">
  <img src="img.jpg" class="card-img-top" alt="...">
  <div class="card-body">
    <h5 class="card-title">タイトル</h5>
    <p class="card-text">説明</p>
    <a href="#" class="btn btn-primary">詳細</a>
  </div>
</div>
```

```html
<!-- BS5 新機能：カードグリッド（等高カード） -->
<div class="row row-cols-1 row-cols-md-3 g-3">
  <div class="col">
    <div class="card h-100">...</div>  <!-- h-100 で高さを揃える -->
  </div>
</div>
```

---

### Lesson 4 — フォーム

**`form-group` が廃止され、スペーシングユーティリティで代替。**
バリデーション状態の付与先が「親要素」から「input 要素自身」に変わった。チェックボックス・ラジオも `form-check` に統一。

| 項目 | Bootstrap 3 | Bootstrap 5 |
|---|---|---|
| フィールドラッパー | `form-group` | `mb-3`（廃止、ユーティリティで代替） |
| ラベル | `<label>` | `<label class="form-label">` |
| 補足テキスト | `<span class="help-block">` | `<div class="form-text">` |
| エラー状態 | 親に `has-error` | input に `is-invalid` |
| 成功状態 | 親に `has-success` | input に `is-valid` |
| エラーメッセージ | `help-block` | `invalid-feedback` / `valid-feedback` |
| チェックボックス | `<div class="checkbox"><label>` | `<div class="form-check">` + `form-check-input` / `form-check-label` |
| ラジオ | `<div class="radio"><label>` | `<div class="form-check">` + `form-check-input` / `form-check-label` |
| インラインフォーム | `form-inline` | `row` + `col-auto` + `align-items-center`（廃止） |
| フローティングラベル | なし | `form-floating`（新機能） |
| セレクトボックス | `form-control` | `form-select` |

**主な書き換え例：**

```html
<!-- BS3: フォームグループ -->
<div class="form-group">
  <label for="email">メール</label>
  <input type="email" class="form-control" id="email">
  <span class="help-block">補足説明</span>
</div>

<!-- BS5: mb-3 で代替 -->
<div class="mb-3">
  <label for="email" class="form-label">メール</label>
  <input type="email" class="form-control" id="email">
  <div class="form-text">補足説明</div>
</div>
```

```html
<!-- BS3: バリデーション（親要素にクラス） -->
<div class="form-group has-error">
  <input class="form-control">
  <span class="help-block">エラーメッセージ</span>
</div>

<!-- BS5: バリデーション（input に直接） -->
<div class="mb-3">
  <input class="form-control is-invalid">
  <div class="invalid-feedback">エラーメッセージ</div>
</div>
```

```html
<!-- BS3: チェックボックス・ラジオ -->
<div class="checkbox">
  <label><input type="checkbox"> 選択肢</label>
</div>
<div class="radio">
  <label><input type="radio"> 選択肢</label>
</div>

<!-- BS5: form-check で統一 -->
<div class="form-check">
  <input class="form-check-input" type="checkbox" id="chk">
  <label class="form-check-label" for="chk">選択肢</label>
</div>
<div class="form-check">
  <input class="form-check-input" type="radio" id="rad">
  <label class="form-check-label" for="rad">選択肢</label>
</div>
```

```html
<!-- BS5 新機能：フローティングラベル -->
<!-- placeholder 属性が必須（ラベル位置の制御に使われる） -->
<div class="form-floating mb-3">
  <input type="email" class="form-control" id="mail" placeholder="dummy">
  <label for="mail">メールアドレス</label>
</div>
<div class="form-floating">
  <select class="form-select" id="sel">
    <option>選択...</option>
  </select>
  <label for="sel">カテゴリ</label>
</div>
```

---

### Lesson 5 — JavaScript / jQuery 不要化

**BS5 最大の変更。jQuery への依存がゼロになった。**
すべての `data-toggle` / `data-target` / `data-dismiss` が `data-bs-*` プレフィックスに変わり、
JavaScript の API も jQuery プラグイン形式から `new bootstrap.Modal()` などの Vanilla JS クラスに変わった。

| 項目 | Bootstrap 3 | Bootstrap 5 |
|---|---|---|
| 依存ライブラリ | jQuery 1.x / 2.x / 3.x が必須 | Vanilla JS のみ |
| JS ファイル | `jquery.min.js` + `bootstrap.min.js` | `bootstrap.bundle.min.js`（Popper.js 内包）のみ |
| トグル属性 | `data-toggle` | `data-bs-toggle` |
| ターゲット属性 | `data-target` | `data-bs-target` |
| 閉じる属性 | `data-dismiss` | `data-bs-dismiss` |
| 閉じるボタン | `<button class="close"><span>&times;</span></button>` | `<button class="btn-close"></button>` |
| 開いた状態 | `collapse in` | `collapse show` |
| アコーディオン親指定 | `data-parent` | `data-bs-parent` |

**読み込みの変更：**

```html
<!-- BS3: jQuery が必須、読み込み順に注意 -->
<script src="jquery.min.js"></script>
<script src="bootstrap.min.js"></script>

<!-- BS5: 1ファイルのみ、jQuery 不要 -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
```

**モーダルの変更：**

```html
<!-- BS3 -->
<button data-toggle="modal" data-target="#myModal">開く</button>
<div class="modal" id="myModal">
  <div class="modal-header">
    <button class="close" data-dismiss="modal"><span>&times;</span></button>
    <h4 class="modal-title">タイトル</h4>
  </div>
</div>

<!-- BS5 -->
<button data-bs-toggle="modal" data-bs-target="#myModal">開く</button>
<div class="modal" id="myModal">
  <div class="modal-header">
    <h1 class="modal-title fs-5">タイトル</h1>
    <button class="btn-close" data-bs-dismiss="modal"></button>
  </div>
</div>
```

**JS API の変更：**

```js
// BS3: jQuery プラグイン
$('#myModal').modal('show')
$('#myModal').modal('hide')
$('#myModal').on('shown.bs.modal', function() { ... })
$('[data-toggle="tooltip"]').tooltip()

// BS5: Vanilla JS クラス
const modal = new bootstrap.Modal('#myModal')
modal.show()
modal.hide()
document.getElementById('myModal').addEventListener('shown.bs.modal', () => { ... })

// Tooltip は明示的な初期化が必要（BS3 も同様だが jQuery なし）
document.querySelectorAll('[data-bs-toggle="tooltip"]')
  .forEach(el => new bootstrap.Tooltip(el))

// 既存インスタンスの取得
const existing = bootstrap.Modal.getInstance('#myModal')
```

**アコーディオンの変更：**

```html
<!-- BS3: panel-group + panel -->
<div class="panel-group" id="accordion">
  <div class="panel panel-default">
    <div class="panel-heading">
      <a data-toggle="collapse" data-parent="#accordion" href="#c1">項目</a>
    </div>
    <div id="c1" class="panel-collapse collapse in">
      <div class="panel-body">内容</div>
    </div>
  </div>
</div>

<!-- BS5: accordion コンポーネント -->
<div class="accordion" id="accordion">
  <div class="accordion-item">
    <h2 class="accordion-header">
      <button class="accordion-button" data-bs-toggle="collapse"
              data-bs-target="#c1" data-bs-parent="#accordion">
        項目
      </button>
    </h2>
    <div id="c1" class="accordion-collapse collapse show">
      <div class="accordion-body">内容</div>
    </div>
  </div>
</div>
```

---

## 全変更点チートシート

### クラス名の変更・廃止

| カテゴリ | Bootstrap 3 | Bootstrap 5 | 備考 |
|---|---|---|---|
| **グリッド** | `col-xs-*` | `col-*` | xs プレフィックス廃止 |
| | `col-md-offset-4` | `offset-md-4` | offset の書式変更 |
| | — | `col`（数値なし） | Auto-layout（新機能） |
| | — | `g-*` / `gx-*` / `gy-*` | Gutter ユーティリティ（新機能） |
| | — | `col-xxl-*` | xxl ブレークポイント（新機能） |
| **ナビバー** | `navbar-default` | `navbar-light` + `bg-light` | |
| | `navbar-inverse` | `navbar-dark` + `bg-dark` | |
| | `navbar-toggle` | `navbar-toggler` | |
| | `icon-bar`（×3） | `navbar-toggler-icon` | |
| | `navbar-header` | 廃止（不要） | |
| | `navbar-nav` の `<li><a>` | `nav-item` + `nav-link` | |
| **カード** | `panel panel-default` | `card` | |
| | `panel-heading` | `card-header` | |
| | `panel-body` | `card-body` | |
| | `panel-footer` | `card-footer` | |
| | `panel-primary` 等 | `text-bg-primary` 等 | |
| | `well` | `card bg-light` | |
| | `well-sm` / `well-lg` | `p-2` / `p-4` | |
| | `thumbnail` | `card` + `card-img-top` | |
| | `caption` | `card-body` | |
| | — | `card-title` / `card-text` | |
| | — | `row-cols-*` / `h-100` | カードグリッド（新機能） |
| **フォーム** | `form-group` | `mb-3`（廃止） | |
| | `help-block` | `form-text` | |
| | `has-error`（親） | `is-invalid`（input） | 付与先が変わった |
| | `has-success`（親） | `is-valid`（input） | 同上 |
| | — | `invalid-feedback` / `valid-feedback` | |
| | `checkbox` / `radio` | `form-check` に統一 | |
| | — | `form-check-input` / `form-check-label` | |
| | — | `form-label` | label クラス追加 |
| | `form-inline` | 廃止（`row col-auto` で代替） | |
| | — | `form-floating` | フローティングラベル（新機能） |
| | `form-control`（select） | `form-select` | select 専用クラス |
| **JS 属性** | `data-toggle` | `data-bs-toggle` | |
| | `data-target` | `data-bs-target` | |
| | `data-dismiss` | `data-bs-dismiss` | |
| | `data-parent` | `data-bs-parent` | |
| | `collapse in` | `collapse show` | |
| **ボタン** | `<button class="close"><span>&times;</span>` | `<button class="btn-close">` | |
| **ドロップダウン** | `<li role="separator">` | `<hr class="dropdown-divider">` | |
| | `<li><a>` | `<a class="dropdown-item">` | |

### その他の主要変更

| 項目 | Bootstrap 3 | Bootstrap 5 |
|---|---|---|
| jQuery 依存 | 必須 | 不要（Vanilla JS） |
| グリッド基盤 | Float | Flexbox |
| Popper.js | 別途読み込み | bundle に内包済み |
| RTL サポート | なし | あり（`dir="rtl"` で有効） |
| CSS カスタムプロパティ | なし | あり（`--bs-primary` 等） |
| ダークモード | なし | `data-bs-theme="dark"` で対応 |

---

## 使用 CDN バージョン

Bootstrap **5.3.3** を固定使用。

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
