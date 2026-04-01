# ps1ファイルはBOM付のUTF8で保存することを推奨します。BOMなしUTF8で保存した場合、PowerShell ISEやVSCodeのターミナルで日本語が文字化けする可能性があります。
# ファイルをリネームしてアーカイブディレクトリに移動するスクリプト
# 引数
param(
    [string]$FilePath,              # 処理対象となるファイルのパス（省略可、デフォルトは "\\TINASHA\share\DTV_mp4"）
    [string]$ArchivePath,           # 格納対象となるディレクトリのパス（省略可、デフォルトは "\\ELAINA\share\DTV_mp4"）
    [System.Boolean]$RenameOnly     # リネームのみ実行するかどうかのフラグ（省略可、デフォルトは $false）
)

# 共通処理インポート
# . \\TINASHA\works\Scripts\PowerShell\common.ps1
. .\common.ps1

# 処理対象となるファイルのパスを指定
# $search_file_path = "\\TINASHA\works\DTV_mp4"
  $search_file_path = "\\TINASHA\share\DTV_mp4\"
  if (-not [string]::IsNullOrEmpty($FilePath)) {
    $search_file_path = $FilePath
  }

# 格納対象となるディレクトリのパスを指定
# $search_dir_path = "\\ELAINA\share\DTV_mp4"
  $search_dir_path = "\\TINASHA\share\DTV_mp4"
  if (-not [string]::IsNullOrEmpty($ArchivePath)) {
    $search_dir_path = $ArchivePath
  }

# リネームのみ実行する（ファイル移動は実施しない）
  $renameOnlyFlg = $false
# $renameOnlyFlg = $true
if ($RenameOnly) {
    $renameOnlyFlg = $true
}

Write-Host ("")
Write-Host ("処理対象となるファイルパス：" + $search_file_path)
Write-Host ("格納対象となるディレクトリ：" + $search_dir_path)
if ($renameOnlyFlg) {
    Write-Host "リネームのみ実行します。ファイル移動は実施しません。"
} else {
    Write-Host "リネームしてファイルを移動します。"
}

$confirmationTitle = "確認"
$confirmationMessage = "処理を継続しますか?"
$confirmationYes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "処理を実行します"
$confirmationNo = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "処理をキャンセルします"
$confirmationOptions = [System.Management.Automation.Host.ChoiceDescription[]]($confirmationYes, $confirmationNo)
$confirmationResult = $host.ui.PromptForChoice($confirmationTitle, $confirmationMessage, $confirmationOptions, 0)
if ($confirmationResult -eq 0) {
    Write-Host "処理を継続します。"
} else {
    Write-Host "処理をキャンセルします。"
    Read-Host "Press Enter to continue..."
    exit 0
}

# 変数宣言  
$files = @()    # ハッシュテーブルの配列
$file = @{}     # 単一のハッシュテーブル

# Get-ChildItemでファイルを取得
$childItems = Get-ChildItem -Path $search_file_path -file -Filter *.mp4
foreach ($childItem in $childItems) {
    $file = @{
        full = $childItem.FullName
        last = $childItem.Name
        base = $childItem.BaseName
        directory = $childItem.DirectoryName
        newbase = Convert-FileName -fileName (Convert-ANiMAZiNGFileName  -fileName $childItem.BaseName)
        extention = $childItem.Extension
    }
    $files += ,@($file)
}

# 対象ファイルがない場合は処理終了
if ($files.Count -eq 0) {
    Write-Host ($search_file_path + " に対象ファイル(.mp4)が見つかりませんでした。処理を終了します。")
    Read-Host "Press Enter to continue..."
    exit 0
}

# 重複削除対象列
$duplicateColumns = @('base')

# ソート対象列と順序
$sortColumnsAndOrder = @(
#    @{ exp = { $_.base }; des = $true }
    @{ exp = { $_.base }; asc = $true }

)
# データ処理（ソートと重複削除）
$sortedFiles = HashTableProcessing -hashTables $files -duplicateKeys $duplicateColumns -sortKeysAndOrder $sortColumnsAndOrder

# ファイル名変更(直接指定)
Write-Host ("---- Rename files")
foreach ($file in $sortedFiles) {
    if ($file.base -ne $file.newbase -and $file.newbase) {
        $msg = "  " + $file.base + " -> " + $file.newbase
        try {
            # -LiteralPath の使用（推奨）:ワイルドカード（*など）として解釈させず、文字列をそのままパスとして扱います。
            Rename-Item -LiteralPath $file.full -NewName ($file.newbase + $file.extention)
        }
        catch {
            $msg += " -> (Failed to rename)" + $_.Exception.Message
        }
        Write-Host ($msg)
    }
}

# リネームだけの場合、ここで処理終了
if ($renameOnlyFlg) {
    Write-Host "ファイルのリネームが完了しました。処理を終了します。"
    Read-Host "Press Enter to continue..."
    exit 0
}

# 変数宣言  
$dirs = @()    # ハッシュテーブルの配列
$dir = @{}     # 単一のハッシュテーブル

# Get-ChildItemでファイルを取得
$childItems = Get-ChildItem -Path $search_dir_path -Directory -Recurse
foreach ($childItem in $childItems) {
    $dir = @{
        full = $childItem.FullName
        last = $childItem.Name
    }
    $dirs += ,@($dir)
}

# 重複削除対象列
$duplicateColumns = @('full')

# ソート対象列と順序
$sortColumnsAndOrder = @(
    @{ exp = { $_.full }; des = $true }
#    @{ exp = { $_.base }; asc = $true }

)
# データ処理（ソートと重複削除）
$sortedDirs = HashTableProcessing -hashTables $dirs -duplicateKeys $duplicateColumns -sortKeysAndOrder $sortColumnsAndOrder

# ファイルを格納するディレクトリを検索しファイル移動する
Write-Host ("---- Searching for directories to store files")
foreach ($sortedFile in $sortedFiles) {
    $msg = "  " + $sortedFile.newbase
    foreach ($sortedDir in $sortedDirs) {
        # 文字列操作(ディレクトリ名がファイル名に含まれる場合) https://qiita.com/daifukusan/items/334a6b2d37c0edf11be6
        # if ($sortedFile.newbase.Contains($sortedDir.last)) {
        if ($sortedFile.newbase.IndexOf($sortedDir.last) -gt 0) {
            $msg += " -> " + $sortedDir.full
            try {
                Move-Item -LiteralPath ($sortedFile.directory + "\" + $sortedFile.newbase + $sortedFile.extention) -Destination $sortedDir.full
            } 
            catch {
                $msg += " -> (Failed to move)" + $_.Exception.Message
            }
            break
        }
    }
    Write-Host ($msg)
}
Write-Host "ファイルのリネームとアーカイブが完了しました。処理を終了します。"
Read-Host "Press Enter to continue..."
exit 0
