# Find-Bootstrap3To53Targets.ps1

Bootstrap 3 系から Bootstrap 5.3 系へ移行する際に、指定フォルダ配下の HTML / JSP / JavaScript ファイルを走査し、変換対象となる Bootstrap 3 固有の記法を洗い出す PowerShell スクリプトです。

## 目的

このスクリプトは、Bootstrap 3 から Bootstrap 5.3 への移行作業において、以下を把握するために使用します。

- 変換対象となるファイル
- 変換対象となる箇所
- 変換ルールごとの件数
- ファイルごとの変換対象件数
- JavaScript ファイル内の Bootstrap 3 jQuery Plugin 呼び出し
- Bootstrap 5.3 変換後に旧記法が残っていないかの確認

既定設定では、Bootstrap 5.3 変換後のファイルでは原則として検出件数が 0 件になるように、Bootstrap 3 固有または廃止された記法を中心に検出します。

## 対象ファイル

指定したルートフォルダ配下の以下のファイルを再帰的に検索します。

| 拡張子 | 対象 |
|---|---|
| `.html` | HTML ファイル |
| `.htm` | HTML ファイル |
| `.jsp` | JSP ファイル |
| `.js` | JavaScript ファイル |

## 主な検出対象

| 分類 | Bootstrap 3 の例 | Bootstrap 5.3 での主な対応 |
|---|---|---|
| グリッド | `col-xs-*` | `col-*` へ変更 |
| ボタン | `btn-default` | `btn-secondary` などへ変更 |
| パネル | `panel`, `panel-default`, `panel-heading`, `panel-body` | `card` 系へ変更 |
| ラベル | `label-primary` など | `badge` 系へ変更 |
| 入力グループ | `input-group-addon`, `input-group-btn` | `input-group-text` などへ変更 |
| フォーム | `form-group`, `control-label`, `form-control-static` | Bootstrap 5.3 のフォーム構造へ変更 |
| ヘルプテキスト | `help-block` | `form-text` へ変更 |
| Glyphicons | `glyphicon`, `glyphicon-*` | Bootstrap Icons などへ変更 |
| ナビゲーション | `navbar-toggle`, `navbar-header`, `navbar-right` | Bootstrap 5.3 の navbar 構造へ変更 |
| data 属性 | `data-toggle`, `data-target`, `data-dismiss` | `data-bs-toggle`, `data-bs-target`, `data-bs-dismiss` へ変更 |
| JavaScript API | `$('#id').modal('show')` など | Bootstrap 5 の JavaScript API へ変更 |
| JavaScript内セレクタ | `[data-toggle="modal"]` など | `[data-bs-toggle="modal"]` などへ変更 |

## 基本的な使い方

```powershell
.\Find-Bootstrap3To53Targets_with_js.ps1 -RootPath C:\work\webapp\src\main\webapp
```

`-RootPath` には、検索対象となる HTML / JSP / JavaScript ファイルが格納されているフォルダを指定します。

## 出力先を指定する場合

```powershell
.\Find-Bootstrap3To53Targets_with_js.ps1 `
  -RootPath C:\work\webapp\src\main\webapp `
  -OutputDir C:\work\bootstrap-scan
```

## 文字コードを指定する場合

古い JSP や HTML が Shift_JIS の場合は、`-EncodingName` を指定します。

```powershell
.\Find-Bootstrap3To53Targets_with_js.ps1 `
  -RootPath C:\work\webapp\src\main\webapp `
  -OutputDir C:\work\bootstrap-scan `
  -EncodingName shift_jis
```

## `.js` を含めたくない場合

今回の更新版では、既定で `.js` が対象に含まれます。

HTML / JSP だけを対象にしたい場合は、`-Extensions` を明示してください。

```powershell
.\Find-Bootstrap3To53Targets_with_js.ps1 `
  -RootPath C:\work\webapp\src\main\webapp `
  -Extensions .html,.htm,.jsp
```

## 変換後チェックとして使う場合

Bootstrap 5.3 への変換後に、旧 Bootstrap 3 記法が残っていないか確認する場合は、オプションなしで実行します。

```powershell
.\Find-Bootstrap3To53Targets_with_js.ps1 -RootPath C:\work\webapp\src\main\webapp
```

この実行で検出件数が 0 件であれば、スクリプトで定義している Bootstrap 3 固有の変換対象は残っていない状態です。

## 広めに棚卸しする場合

変換前の初期調査として、Bootstrap 3 固有とは限らないが確認した方がよい箇所も含めたい場合は、以下のオプションを使用します。

```powershell
.\Find-Bootstrap3To53Targets_with_js.ps1 `
  -RootPath C:\work\webapp\src\main\webapp `
  -IncludeReviewOnly `
  -IncludeAmbiguousDependencyRules
```

この実行では、レビュー目的の広めの検出が含まれます。

そのため、Bootstrap 5.3 変換後でも検出件数が 0 件にならない可能性があります。

変換完了判定には、通常のオプションなし実行を使用してください。

## 出力ファイル

| ファイル名 | 内容 |
|---|---|
| `bootstrap3_to_53_detail.csv` | 検出箇所の明細 |
| `bootstrap3_to_53_rule_summary.csv` | 変換ルール別の件数 |
| `bootstrap3_to_53_file_summary.csv` | ファイル別の件数 |
| `bootstrap3_to_53_report.md` | 人が読むための簡易レポート |

## detail CSV の内容

| 列 | 内容 |
|---|---|
| `File` | 対象ファイルのフルパス |
| `RelativePath` | 走査ルートからの相対パス |
| `Extension` | ファイル拡張子 |
| `Line` | 検出された行番号 |
| `RuleId` | 検出ルール ID |
| `Category` | 分類 |
| `Severity` | 重要度 |
| `Mode` | 検出モード |
| `Bootstrap3` | Bootstrap 3 側の記法 |
| `Bootstrap53` | Bootstrap 5.3 側の対応 |
| `Match` | 検出された文字列 |
| `Snippet` | 対象行周辺の抜粋 |
| `Note` | 補足 |

## 変換完了判定の考え方

Bootstrap 5.3 変換後の確認では、以下の条件を目安にします。

| 確認項目 | 判定 |
|---|---|
| 通常実行の検出件数 | 0 件であること |
| `data-toggle` など旧 data 属性 | 残っていないこと |
| `panel-*` | `card` 系へ置換済みであること |
| `glyphicon-*` | Bootstrap Icons 等へ置換済みであること |
| `btn-default` | `btn-secondary` 等へ置換済みであること |
| `col-xs-*` | `col-*` へ置換済みであること |
| `$('...').modal(...)` など | Bootstrap 5 の JavaScript API へ置換済みであること |

## 注意事項

このスクリプトは、正規表現による静的解析を行います。

そのため、以下のケースでは検出漏れやレビューが必要になる場合があります。

- JavaScript で HTML を動的生成している場合
- JSP の include で画面部品を組み立てている場合
- CSS クラス名を文字列連結している場合
- 独自 CSS で Bootstrap 3 と同じクラス名を使っている場合
- コメントアウトされた古いコードが残っている場合
- `-IncludeReviewOnly` や `-IncludeAmbiguousDependencyRules` を指定している場合

検出結果は、最終的な変換要否を判断するための材料として使用してください。
