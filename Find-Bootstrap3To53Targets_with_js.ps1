<#
.SYNOPSIS
  Bootstrap 3.x から Bootstrap 5.3 への移行対象箇所を、指定フォルダ配下の HTML / JSP / JavaScript から洗い出します。

.DESCRIPTION
  .html / .htm / .jsp / .js を再帰走査し、Bootstrap 3 で使われがちな class、data属性、
  jQuery plugin呼び出しなどを正規表現で検出します。

  既定では、Bootstrap 5.3 変換後のファイルでは原則 0 件になるように、
  Bootstrap 3 固有・廃止記法を中心に検出します。

  出力:
    - bootstrap3_to_53_detail.csv       : 検出箇所の明細。ファイル、行番号、ルール、検出文字列、前後スニペットなど。
    - bootstrap3_to_53_rule_summary.csv : 変換ルール別の件数。
    - bootstrap3_to_53_file_summary.csv : ファイル別の件数。
    - bootstrap3_to_53_report.md        : 人が読むための簡易レポート。

.PARAMETER RootPath
  走査対象のルートフォルダ。

.PARAMETER OutputDir
  結果ファイルの出力先。未指定の場合はカレントディレクトリ配下に日時付きフォルダを作成します。

.PARAMETER Extensions
  走査対象拡張子。既定は .html, .htm, .jsp, .js。

.PARAMETER ExcludeDirs
  走査対象から除外するディレクトリ名。

.PARAMETER EncodingName
  ファイル読み取り時の文字コード。既定は UTF-8。古い JSP が Shift_JIS の場合は -EncodingName shift_jis を指定してください。

.PARAMETER IncludeMinified
  *.min.js / *.min.html など minified と推定されるファイルも対象にします。既定では除外します。

.PARAMETER IncludeReviewOnly
  Bootstrap 3 固有とは限らないが、移行時に確認した方がよい候補も検出します。
  変換後ゼロ件判定には使用しないでください。

.PARAMETER IncludeAmbiguousDependencyRules
  bootstrap.min.css / bootstrap.min.js / jquery.js など、バージョン判定が曖昧な依存関係も検出します。
  変換後ゼロ件判定には使用しないでください。

.EXAMPLE
  .\Find-Bootstrap3To53Targets.ps1 -RootPath C:\work\webapp\src\main\webapp

.EXAMPLE
  .\Find-Bootstrap3To53Targets.ps1 -RootPath C:\work\webapp -OutputDir C:\work\bootstrap-scan -EncodingName shift_jis

.EXAMPLE
  .\Find-Bootstrap3To53Targets.ps1 -RootPath C:\work\webapp -IncludeReviewOnly -IncludeAmbiguousDependencyRules
#>

[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [ValidateNotNullOrEmpty()]
  [string]$RootPath,

  [string]$OutputDir = (Join-Path (Get-Location) ("bootstrap3_to_53_scan_" + (Get-Date -Format "yyyyMMdd_HHmmss"))),

  [string[]]$Extensions = @(".html", ".htm", ".jsp", ".js"),

  [string[]]$ExcludeDirs = @(".git", ".svn", "node_modules", "target", "build", "dist", "vendor", "coverage"),

  [string]$EncodingName = "UTF-8",

  [switch]$IncludeMinified,

  [switch]$IncludeReviewOnly,

  [switch]$IncludeAmbiguousDependencyRules
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function New-BootstrapRule {
  param(
    [string]$Id,
    [string]$Category,
    [string]$Bootstrap3,
    [string]$Bootstrap53,
    [string]$Pattern,
    [string]$Severity = "Medium",
    [string]$Note = "",
    [ValidateSet("Strict", "ReviewOnly", "AmbiguousDependency")]
    [string]$Mode = "Strict"
  )

  [pscustomobject]@{
    Id          = $Id
    Category    = $Category
    Bootstrap3  = $Bootstrap3
    Bootstrap53 = $Bootstrap53
    Pattern     = $Pattern
    Severity    = $Severity
    Note        = $Note
    Mode        = $Mode
  }
}

# Bootstrap 3 -> Bootstrap 5.3 変換仕様をもとにした検出ルール。
# 既定の Strict ルールは、Bootstrap 5.3 変換後に原則 0 件になることを狙い、
# Bootstrap 3 固有・廃止記法に絞っています。
$AllRules = @(
  # 依存関係 / 読み込み
  (New-BootstrapRule "DEP001" "依存関係" "Bootstrap 3 CSS明示参照" "Bootstrap 5.3 CSS" 'bootstrap(?:\.min)?\.css[^''"`\r\n]*?(?:3\.[0-9]|bootstrap/3|bootstrap@3|bootstrap-3)' "High" "Bootstrap 3 と判定できるCSS参照。5.3系CSSへ差し替え。"),
  (New-BootstrapRule "DEP002" "依存関係" "Bootstrap 3 JS明示参照" "Bootstrap 5.3 bundle JS" 'bootstrap(?:\.min)?\.js[^''"`\r\n]*?(?:3\.[0-9]|bootstrap/3|bootstrap@3|bootstrap-3)' "High" "Bootstrap 3 と判定できるJS参照。bootstrap.bundle.min.jsへ差し替え。"),

  # バージョン判定が曖昧な依存関係。既定では対象外。
  (New-BootstrapRule "DEP901" "依存関係" "bootstrap.min.css等" "Bootstrap 5.3 CSS" 'bootstrap(?:\.min)?\.css' "Low" "ファイル名だけでは3系/5.3系を判定できないため要確認。" "AmbiguousDependency"),
  (New-BootstrapRule "DEP902" "依存関係" "bootstrap.min.js等" "Bootstrap 5.3 bundle JS" 'bootstrap(?:\.min)?\.js' "Low" "ファイル名だけでは3系/5.3系を判定できないため要確認。" "AmbiguousDependency"),
  (New-BootstrapRule "DEP903" "依存関係" "jQuery参照" "Bootstrap用途なら不要" 'jquery(?:\.min)?\.js' "Low" "Bootstrap 5ではjQuery不要。ただし独自処理で使う場合は別判断。" "AmbiguousDependency"),

  # グリッド / レイアウト
  (New-BootstrapRule "GRID001" "グリッド" ".col-xs-*" ".col-*" '(?<![\w-])col-xs-\d{1,2}(?![\w-])' "High" "xs接頭辞を削除。例: col-xs-6 -> col-6。"),
  (New-BootstrapRule "GRID002" "グリッド" ".col-*-offset-*" ".offset-*-*" '(?<![\w-])col-(?:xs|sm|md|lg)-offset-\d{1,2}(?![\w-])' "High" "offset構文へ変換。例: col-md-offset-2 -> offset-md-2。"),
  (New-BootstrapRule "GRID003" "グリッド" ".col-*-push-*" ".order-*" '(?<![\w-])col-(?:xs|sm|md|lg)-push-\d{1,2}(?![\w-])' "High" "pushはorder utilityへ再設計。機械変換は要注意。"),
  (New-BootstrapRule "GRID004" "グリッド" ".col-*-pull-*" ".order-*" '(?<![\w-])col-(?:xs|sm|md|lg)-pull-\d{1,2}(?![\w-])' "High" "pullはorder utilityへ再設計。機械変換は要注意。"),

  # Utility
  (New-BootstrapRule "UTIL001" "Utility" ".pull-left" ".float-start" '(?<![\w-])pull-left(?![\w-])' "High" "RTL対応のstart/end命名へ変換。"),
  (New-BootstrapRule "UTIL002" "Utility" ".pull-right" ".float-end" '(?<![\w-])pull-right(?![\w-])' "High" "RTL対応のstart/end命名へ変換。"),
  (New-BootstrapRule "UTIL003" "Utility" ".center-block" ".mx-auto .d-block" '(?<![\w-])center-block(?![\w-])' "Medium" "中央寄せは mx-auto d-block などへ。"),
  (New-BootstrapRule "UTIL004" "Utility" ".hidden-*" ".d-*" '(?<![\w-])hidden-(?:xs|sm|md|lg)(?:-(?:up|down))?(?![\w-])' "High" "display utilityへ変換。表示種別 block/inline/flex は画面要件で判断。"),
  (New-BootstrapRule "UTIL005" "Utility" ".visible-*" ".d-*" '(?<![\w-])visible-(?:xs|sm|md|lg)(?:-(?:block|inline|inline-block))?(?![\w-])' "High" "display utilityへ変換。画面確認必須。"),
  (New-BootstrapRule "UTIL006" "Utility" ".text-left" ".text-start" '(?<![\w-])text-left(?![\w-])' "Medium" "start/end命名へ変換。"),
  (New-BootstrapRule "UTIL007" "Utility" ".text-right" ".text-end" '(?<![\w-])text-right(?![\w-])' "Medium" "start/end命名へ変換。"),
  (New-BootstrapRule "UTIL008" "Utility" ".navbar-left / .navbar-right" ".me-auto / .ms-auto など" '(?<![\w-])navbar-(?:left|right)(?![\w-])' "High" "navbar内の配置はflex/spacing utilityで再設計。"),

  # 画像 / テーブル
  (New-BootstrapRule "IMG001" "画像" ".img-responsive" ".img-fluid" '(?<![\w-])img-responsive(?![\w-])' "Medium" "レスポンシブ画像。"),
  (New-BootstrapRule "IMG002" "画像" ".img-rounded" ".rounded" '(?<![\w-])img-rounded(?![\w-])' "Low" "角丸。"),
  (New-BootstrapRule "IMG003" "画像" ".img-circle" ".rounded-circle" '(?<![\w-])img-circle(?![\w-])' "Low" "円形。"),
  (New-BootstrapRule "TBL001" "テーブル" ".table-condensed" ".table-sm" '(?<![\w-])table-condensed(?![\w-])' "Medium" "コンパクトテーブル。"),

  # フォーム
  (New-BootstrapRule "FORM001" "フォーム" ".form-group" ".mb-3等" '(?<![\w-])form-group(?![\w-])' "High" "フォーム部品の余白はspacing utilityへ。"),
  (New-BootstrapRule "FORM002" "フォーム" ".control-label" ".form-label" '(?<![\w-])control-label(?![\w-])' "High" "labelに明示。"),
  (New-BootstrapRule "FORM003" "フォーム" ".input-lg/.input-sm" ".form-control-lg/.form-control-sm" '(?<![\w-])input-(?:lg|sm)(?![\w-])' "Medium" "入力サイズ指定を変換。"),
  (New-BootstrapRule "FORM004" "フォーム" ".has-error/.has-warning/.has-success" ".is-invalid/.is-valid等" '(?<![\w-])has-(?:error|warning|success)(?![\w-])' "High" "Validation表現へ変換。DOM構造も見直し。"),
  (New-BootstrapRule "FORM005" "フォーム" ".help-block" ".form-text / .invalid-feedback" '(?<![\w-])help-block(?![\w-])' "High" "補足テキストかエラー表示かで変換先を判断。"),
  (New-BootstrapRule "FORM006" "フォーム" ".input-group-addon" ".input-group-text" '(?<![\w-])input-group-addon(?![\w-])' "High" "input groupのDOM構造も確認。"),
  (New-BootstrapRule "FORM007" "フォーム" ".input-group-btn" "buttonをinput-group内に直接配置" '(?<![\w-])input-group-btn(?![\w-])' "High" "Bootstrap 5では不要。構造変更。"),
  (New-BootstrapRule "FORM008" "フォーム" ".checkbox-inline/.radio-inline" ".form-check .form-check-inline" '(?<![\w-])(?:checkbox|radio)-inline(?![\w-])' "Medium" "inline form-checkへ変換。"),

  # コンポーネント
  (New-BootstrapRule "CMP001" "Buttons" ".btn-default" ".btn-secondary / .btn-light等" '(?<![\w-])btn-default(?![\w-])' "High" "default色は廃止。意味に応じてsecondary/light等を選択。"),
  (New-BootstrapRule "CMP002" "Buttons" ".btn-xs" ".btn-sm または独自CSS" '(?<![\w-])btn-xs(?![\w-])' "Medium" "xsサイズは標準なし。"),
  (New-BootstrapRule "CMP003" "Buttons" ".btn-block" ".d-gridで親を囲む" '(?<![\w-])btn-block(?![\w-])' "High" "ボタン自体ではなく親要素側で表現することが多い。"),
  (New-BootstrapRule "CMP004" "Labels" ".label .label-*" ".badge .text-bg-*" '(?<![\w-])label-(?:default|primary|success|info|warning|danger)(?![\w-])|(?<=class\s*=\s*["''][^"'']*)(?<![\w-])label(?![\w-])' "Medium" "labelはbadgeへ統合。"),
  (New-BootstrapRule "CMP005" "Panels" ".panel" ".card" '(?<![\w-])panel(?:-(?:default|primary|success|info|warning|danger))?(?![\w-])' "High" "Cardへ変換。DOM構造変更。"),
  (New-BootstrapRule "CMP006" "Panels" ".panel-heading" ".card-header" '(?<![\w-])panel-heading(?![\w-])' "High" "Card headerへ。"),
  (New-BootstrapRule "CMP007" "Panels" ".panel-body" ".card-body" '(?<![\w-])panel-body(?![\w-])' "High" "Card bodyへ。"),
  (New-BootstrapRule "CMP008" "Panels" ".panel-footer" ".card-footer" '(?<![\w-])panel-footer(?![\w-])' "High" "Card footerへ。"),
  (New-BootstrapRule "CMP009" "Panels" ".panel-title" ".card-title" '(?<![\w-])panel-title(?![\w-])' "Medium" "Card titleへ。"),
  (New-BootstrapRule "CMP010" "Wells" ".well" ".card .card-body等" '(?<![\w-])well(?:-lg|-sm)?(?![\w-])' "Medium" "wellは廃止。用途に応じてcard/utilityへ。"),
  (New-BootstrapRule "CMP011" "Thumbnails" ".thumbnail" ".card / .img-thumbnail" '(?<![\w-])thumbnail(?![\w-])' "Medium" "一覧カードか画像装飾かで変換先を判断。"),
  (New-BootstrapRule "CMP012" "Glyphicons" ".glyphicon" "Bootstrap Icons等" '(?<![\w-])glyphicon(?:-[\w-]+)?(?![\w-])' "High" "Glyphiconsは同梱されない。アイコンライブラリ選定が必要。"),
  (New-BootstrapRule "CMP013" "Navbar" ".navbar-default/.navbar-inverse" ".navbar-light/.navbar-dark + bg-*等" '(?<![\w-])navbar-(?:default|inverse)(?![\w-])' "High" "色指定と背景指定を再設計。"),
  (New-BootstrapRule "CMP014" "Navbar" ".navbar-toggle" ".navbar-toggler" '(?<![\w-])navbar-toggle(?![\w-])' "High" "data属性とicon構造も変更。"),
  (New-BootstrapRule "CMP015" "Navbar" ".navbar-header" "廃止 / flex構造へ" '(?<![\w-])navbar-header(?![\w-])' "High" "Bootstrap 5のnavbar構造へ変更。"),
  (New-BootstrapRule "CMP016" "Navs" ".nav-stacked" ".flex-column" '(?<![\w-])nav-stacked(?![\w-])' "Medium" "縦並びnavへ。"),
  (New-BootstrapRule "CMP017" "List group" ".list-group-item-heading/text" "見出し/本文を通常要素+utilityで表現" '(?<![\w-])list-group-item-(?:heading|text)(?![\w-])' "Medium" "専用クラス廃止。"),

  # JavaScript data属性
  (New-BootstrapRule "DATA001" "data属性" "data-toggle" "data-bs-toggle" '\bdata-toggle\s*=' "High" "Bootstrap JS用data属性にbs名前空間を付与。"),
  (New-BootstrapRule "DATA002" "data属性" "data-target" "data-bs-target" '\bdata-target\s*=' "High" "collapse/modal/tab等のターゲット指定。"),
  (New-BootstrapRule "DATA003" "data属性" "data-dismiss" "data-bs-dismiss" '\bdata-dismiss\s*=' "High" "modal/alert等のdismiss。"),
  (New-BootstrapRule "DATA004" "data属性" "data-parent" "data-bs-parent" '\bdata-parent\s*=' "Medium" "accordion/collapse。"),
  (New-BootstrapRule "DATA005" "data属性" "data-ride" "data-bs-ride" '\bdata-ride\s*=' "Medium" "carousel等。"),
  (New-BootstrapRule "DATA006" "data属性" "data-slide" "data-bs-slide" '\bdata-slide\s*=' "Medium" "carousel control。"),
  (New-BootstrapRule "DATA007" "data属性" "data-slide-to" "data-bs-slide-to" '\bdata-slide-to\s*=' "Medium" "carousel indicator。"),
  (New-BootstrapRule "DATA008" "data属性" "data-spy" "data-bs-spy" '\bdata-spy\s*=' "Medium" "scrollspy。"),
  (New-BootstrapRule "DATA009" "data属性" "data-offset" "data-bs-offset" '\bdata-offset\s*=' "Low" "scrollspy等。"),
  (New-BootstrapRule "DATA010" "data属性" "data-keyboard" "data-bs-keyboard" '\bdata-keyboard\s*=' "Low" "modal等。"),
  (New-BootstrapRule "DATA011" "data属性" "data-backdrop" "data-bs-backdrop" '\bdata-backdrop\s*=' "Medium" "modal。static等の挙動確認。"),

  # JavaScript / jQuery plugin呼び出し。HTML/JSP内scriptと.jsファイルの両方を対象にする。
  (New-BootstrapRule "JS001" "JavaScript" "$('...').modal(...) 等" "bootstrap.Modal等のAPI" '\$\s*\([^;\r\n]*?\)\s*\.\s*(modal|collapse|dropdown|tab|tooltip|popover|carousel|alert|button)\s*\(' "High" "BootstrapのjQuery plugin呼び出しをVanilla JS APIへ変換。"),
  (New-BootstrapRule "JS002" "JavaScript" "data-toggle selector" "data-bs-toggle selector" '\[data-toggle=["''][^"'']+["'']\]' "High" "JS内セレクタもdata-bs-*へ変更。"),
  (New-BootstrapRule "JS003" "JavaScript" "data-target selector" "data-bs-target selector" '\[data-target=["''][^"'']+["'']\]' "High" "JS内セレクタもdata-bs-*へ変更。"),

  # レビュー用。既定では対象外。
  (New-BootstrapRule "REV001" "JavaScript" "$(document).ready(...)" "DOMContentLoaded等" '\$\s*\(\s*document\s*\)\.ready\s*\(' "Low" "Bootstrap固有ではないがjQuery依存削減候補。" "ReviewOnly"),
  (New-BootstrapRule "REV002" "依存関係" "$(...), jQuery(...)" "独自jQuery利用は個別判断" '\$\s*\(|jQuery\s*\(' "Low" "Bootstrap用途か独自処理かを確認。" "ReviewOnly"),
  (New-BootstrapRule "REV003" "グリッド" ".container-fluid / .row" "原則維持" '(?<![\w-])(?:container-fluid|row)(?![\w-])' "Low" "原則維持だが、グリッド幅・gutter差分を画面確認。" "ReviewOnly"),
  (New-BootstrapRule "REV004" "テーブル" ".success/.info/.warning/.danger" ".table-success等" '(?<![\w-])(?:success|info|warning|danger)(?![\w-])' "Low" "table行/セルで使われている場合は table-* へ。一般クラスとの誤検出に注意。" "ReviewOnly"),
  (New-BootstrapRule "REV005" "ARIA/構造" "aria-expanded等" "原則維持だが構造確認" '\baria-(?:expanded|controls|labelledby|hidden)\s*=' "Low" "navbar/collapse/modal/dropdownで構造変更時に整合性を確認。" "ReviewOnly")
)

$Rules = $AllRules | Where-Object {
  ($_.Mode -eq "Strict") -or
  ($IncludeReviewOnly -and $_.Mode -eq "ReviewOnly") -or
  ($IncludeAmbiguousDependencyRules -and $_.Mode -eq "AmbiguousDependency")
}

function Test-ExcludedPath {
  param([string]$Path, [string[]]$Names)
  $segments = $Path -split '[\\/]+'
  foreach ($name in $Names) {
    if ($segments -contains $name) { return $true }
  }
  return $false
}

function Read-TextFile {
  param([string]$Path, [string]$EncodingName)
  $encoding = [System.Text.Encoding]::GetEncoding($EncodingName)
  $reader = New-Object System.IO.StreamReader($Path, $encoding, $true)
  try {
    return $reader.ReadToEnd()
  }
  finally {
    $reader.Close()
  }
}

function Get-LineStarts {
  param([string]$Text)
  $starts = New-Object System.Collections.Generic.List[int]
  $starts.Add(0)
  for ($i = 0; $i -lt $Text.Length; $i++) {
    if ($Text[$i] -eq "`n") {
      $starts.Add($i + 1)
    }
  }
  return $starts
}

function Get-LineNumberFromIndex {
  param(
    [System.Collections.Generic.List[int]]$LineStarts,
    [int]$Index
  )
  $low = 0
  $high = $LineStarts.Count - 1
  while ($low -le $high) {
    $mid = [int](($low + $high) / 2)
    if ($LineStarts[$mid] -le $Index) {
      $low = $mid + 1
    }
    else {
      $high = $mid - 1
    }
  }
  return $high + 1
}

function Get-Snippet {
  param(
    [string]$Text,
    [int]$Index,
    [int]$Length,
    [int]$Around = 60
  )
  $start = [Math]::Max(0, $Index - $Around)
  $end = [Math]::Min($Text.Length, $Index + $Length + $Around)
  $snippet = $Text.Substring($start, $end - $start)
  $snippet = $snippet -replace "`r", " " -replace "`n", " " -replace "\s+", " "
  return $snippet.Trim()
}

function ConvertTo-MarkdownCell {
  param([object]$Value)
  if ($null -eq $Value) { return "" }
  return ([string]$Value) -replace '\|', '\|' -replace "`r", " " -replace "`n", " "
}

if (-not (Test-Path -LiteralPath $RootPath)) {
  throw "RootPath が存在しません: $RootPath"
}

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

$rootFullPath = (Resolve-Path -LiteralPath $RootPath).Path
$normalizedExtensions = $Extensions | ForEach-Object { if ($_.StartsWith('.')) { $_.ToLowerInvariant() } else { ".$($_.ToLowerInvariant())" } }

$files = Get-ChildItem -LiteralPath $rootFullPath -Recurse -File |
  Where-Object {
    $ext = $_.Extension.ToLowerInvariant()
    ($normalizedExtensions -contains $ext) -and
    (-not (Test-ExcludedPath -Path $_.FullName -Names $ExcludeDirs)) -and
    ($IncludeMinified -or ($_.Name -notmatch '\.min\.'))
  }

$details = New-Object System.Collections.Generic.List[object]
$readErrors = New-Object System.Collections.Generic.List[object]

foreach ($file in $files) {
  try {
    $content = Read-TextFile -Path $file.FullName -EncodingName $EncodingName
  }
  catch {
    $readErrors.Add([pscustomobject]@{
      File  = $file.FullName
      Error = $_.Exception.Message
    }) | Out-Null
    continue
  }

  if ([string]::IsNullOrEmpty($content)) { continue }
  $lineStarts = Get-LineStarts -Text $content

  foreach ($rule in $Rules) {
    $matches = [System.Text.RegularExpressions.Regex]::Matches(
      $content,
      $rule.Pattern,
      [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
    )
    foreach ($match in $matches) {
      $lineNumber = Get-LineNumberFromIndex -LineStarts $lineStarts -Index $match.Index
      $relativePath = $file.FullName.Substring($rootFullPath.Length).TrimStart('\', '/')
      $details.Add([pscustomobject]@{
        File            = $file.FullName
        RelativePath    = $relativePath
        Extension       = $file.Extension.ToLowerInvariant()
        Line            = $lineNumber
        RuleId          = $rule.Id
        Category        = $rule.Category
        Severity        = $rule.Severity
        Mode            = $rule.Mode
        Bootstrap3      = $rule.Bootstrap3
        Bootstrap53     = $rule.Bootstrap53
        Match           = $match.Value
        Snippet         = Get-Snippet -Text $content -Index $match.Index -Length $match.Length
        Note            = $rule.Note
      }) | Out-Null
    }
  }
}

$detailPath = Join-Path $OutputDir "bootstrap3_to_53_detail.csv"
$ruleSummaryPath = Join-Path $OutputDir "bootstrap3_to_53_rule_summary.csv"
$fileSummaryPath = Join-Path $OutputDir "bootstrap3_to_53_file_summary.csv"
$errorPath = Join-Path $OutputDir "bootstrap3_to_53_read_errors.csv"
$reportPath = Join-Path $OutputDir "bootstrap3_to_53_report.md"

$details |
  Sort-Object File, Line, RuleId |
  Export-Csv -LiteralPath $detailPath -NoTypeInformation -Encoding UTF8

$ruleSummary = $details |
  Group-Object RuleId, Category, Severity, Mode, Bootstrap3, Bootstrap53, Note |
  ForEach-Object {
    $first = $_.Group | Select-Object -First 1
    [pscustomobject]@{
      RuleId      = $first.RuleId
      Category    = $first.Category
      Severity    = $first.Severity
      Mode        = $first.Mode
      Bootstrap3  = $first.Bootstrap3
      Bootstrap53 = $first.Bootstrap53
      Count       = $_.Count
      FileCount   = ($_.Group | Select-Object -ExpandProperty File -Unique).Count
      Note        = $first.Note
    }
  } |
  Sort-Object @{ Expression = 'Count'; Descending = $true }, RuleId

$ruleSummary | Export-Csv -LiteralPath $ruleSummaryPath -NoTypeInformation -Encoding UTF8

$fileSummary = $details |
  Group-Object File |
  ForEach-Object {
    [pscustomobject]@{
      File       = $_.Name
      Count      = $_.Count
      High       = ($_.Group | Where-Object { $_.Severity -eq 'High' }).Count
      Medium     = ($_.Group | Where-Object { $_.Severity -eq 'Medium' }).Count
      Low        = ($_.Group | Where-Object { $_.Severity -eq 'Low' }).Count
      Categories = (($_.Group | Select-Object -ExpandProperty Category -Unique) -join ', ')
    }
  } |
  Sort-Object @{ Expression = 'Count'; Descending = $true }, File

$fileSummary | Export-Csv -LiteralPath $fileSummaryPath -NoTypeInformation -Encoding UTF8

if ($readErrors.Count -gt 0) {
  $readErrors | Export-Csv -LiteralPath $errorPath -NoTypeInformation -Encoding UTF8
}

$totalCount = $details.Count
$totalFiles = $files.Count
$hitFiles = ($details | Select-Object -ExpandProperty File -Unique).Count
$highCount = ($details | Where-Object { $_.Severity -eq 'High' }).Count
$mediumCount = ($details | Where-Object { $_.Severity -eq 'Medium' }).Count
$lowCount = ($details | Where-Object { $_.Severity -eq 'Low' }).Count

$topRules = $ruleSummary | Select-Object -First 15
$topFiles = $fileSummary | Select-Object -First 15

$report = New-Object System.Collections.Generic.List[string]
$report.Add("# Bootstrap 3.x -> Bootstrap 5.3 変換対象洗い出しレポート")
$report.Add("")
$report.Add("- 走査ルート: `$rootFullPath`")
$report.Add("- 走査対象拡張子: `$($normalizedExtensions -join ', ')`")
$report.Add("- 走査ファイル数: $totalFiles")
$report.Add("- 検出ファイル数: $hitFiles")
$report.Add("- 検出件数: $totalCount")
$report.Add("- 重要度 High: $highCount / Medium: $mediumCount / Low: $lowCount")
$report.Add("- IncludeReviewOnly: $($IncludeReviewOnly.IsPresent)")
$report.Add("- IncludeAmbiguousDependencyRules: $($IncludeAmbiguousDependencyRules.IsPresent)")
$report.Add("- 出力先: `$OutputDir`")
$report.Add("")
$report.Add("## 変換ルール別 上位")
$report.Add("")
$report.Add("| RuleId | Category | Severity | Mode | Bootstrap 3 | Bootstrap 5.3 | Count | FileCount |")
$report.Add("|---|---|---|---|---|---|---:|---:|")
foreach ($r in $topRules) {
  $report.Add("| $(ConvertTo-MarkdownCell $r.RuleId) | $(ConvertTo-MarkdownCell $r.Category) | $(ConvertTo-MarkdownCell $r.Severity) | $(ConvertTo-MarkdownCell $r.Mode) | $(ConvertTo-MarkdownCell $r.Bootstrap3) | $(ConvertTo-MarkdownCell $r.Bootstrap53) | $($r.Count) | $($r.FileCount) |")
}
$report.Add("")
$report.Add("## ファイル別 上位")
$report.Add("")
$report.Add("| File | Count | High | Medium | Low | Categories |")
$report.Add("|---|---:|---:|---:|---:|---|")
foreach ($f in $topFiles) {
  $report.Add("| $(ConvertTo-MarkdownCell $f.File) | $($f.Count) | $($f.High) | $($f.Medium) | $($f.Low) | $(ConvertTo-MarkdownCell $f.Categories) |")
}
$report.Add("")
$report.Add("## 出力ファイル")
$report.Add("")
$report.Add("- 詳細: `$detailPath`")
$report.Add("- ルール別集計: `$ruleSummaryPath`")
$report.Add("- ファイル別集計: `$fileSummaryPath`")
if ($readErrors.Count -gt 0) {
  $report.Add("- 読み取りエラー: `$errorPath`")
}
$report.Add("")
$report.Add("## 注意")
$report.Add("")
$report.Add("このスクリプトは正規表現による静的検出です。JSPの条件分岐、include後のDOM、JavaScriptで動的生成されるHTML、独自CSSの意味までは判断しません。Highの検出箇所から優先的にレビューしてください。")
$report.Add("")
$report.Add("変換完了判定では、`-IncludeReviewOnly` と `-IncludeAmbiguousDependencyRules` を指定しない通常実行の検出件数 0 件を目安にしてください。")

$report | Set-Content -LiteralPath $reportPath -Encoding UTF8

Write-Host "Bootstrap 3.x -> 5.3 変換対象の洗い出しが完了しました。"
Write-Host "走査対象拡張子: $($normalizedExtensions -join ', ')"
Write-Host "走査ファイル数: $totalFiles"
Write-Host "検出ファイル数: $hitFiles"
Write-Host "検出件数: $totalCount"
Write-Host "出力先: $OutputDir"
Write-Host "詳細CSV: $detailPath"
Write-Host "ルール別CSV: $ruleSummaryPath"
Write-Host "ファイル別CSV: $fileSummaryPath"
Write-Host "レポート: $reportPath"
