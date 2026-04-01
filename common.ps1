# ps1ファイルはBOM付のUTF8で保存することを推奨します。BOMなしUTF8で保存した場合、PowerShell ISEやVSCodeのターミナルで日本語が文字化けする可能性があります。
function HashTableProcessing {
    param (
        [Parameter(Mandatory = $true)]
        [array]$hashTables,       # 処理対象のハッシュテーブルの配列
        [string[]]$duplicateKeys, # 重複を削除する列のキー名配列
        $sortKeysAndOrder         # ソートする列とその順序を定義したハッシュテーブル
    )
    # ソート処理
    if ($sortKeysAndOrder) {
        $hashTables = $hashTables | Sort-Object $sortKeysAndOrder
    }

    # 重複データ削除
    if ($duplicateKeys) {
        $seen = @{}
        $uniqueResult = @()

        foreach ($hashTable in $hashTables) {
            $keyValues = $duplicateKeys | ForEach-Object { $hashTable.$_ }
            $compositeKey = $keyValues -join '|'

            if (-not $seen.ContainsKey($compositeKey)) {
                $seen[$compositeKey] = $true
                $uniqueResult += $hashTable
            }
        }
        $hashTables = $uniqueResult
    }

    return $hashTables
}

function Convert-FileName {
# ファイル名を成形する関数
    param (
        [string]$fileName
    )
    # 置換処理の例
    foreach ($replacement in @(
        [ordered]@{ org = "　" ; rep = " " },
        [ordered]@{ org = "！" ; rep = "!" },
        [ordered]@{ org = "＃" ; rep = "#" },
        [ordered]@{ org = "＄" ; rep = "$" },
        [ordered]@{ org = "％" ; rep = "%" },
        [ordered]@{ org = "＆" ; rep = "&" },
        [ordered]@{ org = "（" ; rep = "(" },
        [ordered]@{ org = "）" ; rep = ")" },
        [ordered]@{ org = "［" ; rep = "[" },
        [ordered]@{ org = "］" ; rep = "]" },
        [ordered]@{ org = "－" ; rep = "-" },
        [ordered]@{ org = "．" ; rep = "." },
        [ordered]@{ org = "０" ; rep = "0" },
        [ordered]@{ org = "１" ; rep = "1" },
        [ordered]@{ org = "２" ; rep = "2" },
        [ordered]@{ org = "３" ; rep = "3" },
        [ordered]@{ org = "４" ; rep = "4" },
        [ordered]@{ org = "５" ; rep = "5" },
        [ordered]@{ org = "６" ; rep = "6" },
        [ordered]@{ org = "７" ; rep = "7" },
        [ordered]@{ org = "８" ; rep = "8" },
        [ordered]@{ org = "９" ; rep = "9" },
        [ordered]@{ org = "ａ" ; rep = "a" },
        [ordered]@{ org = "ｂ" ; rep = "b" },
        [ordered]@{ org = "ｃ" ; rep = "c" },
        [ordered]@{ org = "ｄ" ; rep = "d" },
        [ordered]@{ org = "ｅ" ; rep = "e" },
        [ordered]@{ org = "ｆ" ; rep = "f" },
        [ordered]@{ org = "ｇ" ; rep = "g" },
        [ordered]@{ org = "ｈ" ; rep = "h" },
        [ordered]@{ org = "ｉ" ; rep = "i" },
        [ordered]@{ org = "ｊ" ; rep = "j" },
        [ordered]@{ org = "ｋ" ; rep = "k" },
        [ordered]@{ org = "ｌ" ; rep = "l" },
        [ordered]@{ org = "ｍ" ; rep = "m" },
        [ordered]@{ org = "ｎ" ; rep = "n" },
        [ordered]@{ org = "ｏ" ; rep = "o" },
        [ordered]@{ org = "ｐ" ; rep = "p" },
        [ordered]@{ org = "ｑ" ; rep = "q" },
        [ordered]@{ org = "ｒ" ; rep = "r" },
        [ordered]@{ org = "ｓ" ; rep = "s" },
        [ordered]@{ org = "ｔ" ; rep = "t" },
        [ordered]@{ org = "ｕ" ; rep = "u" },
        [ordered]@{ org = "ｖ" ; rep = "v" },
        [ordered]@{ org = "ｗ" ; rep = "w" },
        [ordered]@{ org = "ｘ" ; rep = "x" },
        [ordered]@{ org = "ｙ" ; rep = "y" },
        [ordered]@{ org = "ｚ" ; rep = "z" },
        [ordered]@{ org = "Ａ" ; rep = "A" },
        [ordered]@{ org = "Ｂ" ; rep = "B" },
        [ordered]@{ org = "Ｃ" ; rep = "C" },
        [ordered]@{ org = "Ｄ" ; rep = "D" },
        [ordered]@{ org = "Ｅ" ; rep = "E" },
        [ordered]@{ org = "Ｆ" ; rep = "F" },
        [ordered]@{ org = "Ｇ" ; rep = "G" },
        [ordered]@{ org = "Ｈ" ; rep = "H" },
        [ordered]@{ org = "Ｉ" ; rep = "I" },
        [ordered]@{ org = "Ｊ" ; rep = "J" },
        [ordered]@{ org = "Ｋ" ; rep = "K" },
        [ordered]@{ org = "Ｌ" ; rep = "L" },
        [ordered]@{ org = "Ｍ" ; rep = "M" },
        [ordered]@{ org = "Ｎ" ; rep = "N" },
        [ordered]@{ org = "Ｏ" ; rep = "O" },
        [ordered]@{ org = "Ｐ" ; rep = "P" },
        [ordered]@{ org = "Ｑ" ; rep = "Q" },
        [ordered]@{ org = "Ｒ" ; rep = "R" },
        [ordered]@{ org = "Ｓ" ; rep = "S" },
        [ordered]@{ org = "Ｔ" ; rep = "T" },
        [ordered]@{ org = "Ｕ" ; rep = "U" },
        [ordered]@{ org = "Ｖ" ; rep = "V" },
        [ordered]@{ org = "Ｗ" ; rep = "W" },
        [ordered]@{ org = "Ｘ" ; rep = "X" },
        [ordered]@{ org = "Ｙ" ; rep = "Y" },
        [ordered]@{ org = "Ｚ" ; rep = "Z" },
        [ordered]@{ org = "[字]" ; rep = "" },
        [ordered]@{ org = "[新]" ; rep = "" },
        [ordered]@{ org = "[SS]" ; rep = "" },
        [ordered]@{ org = "[デ]" ; rep = "" },
        [ordered]@{ org = "[解]" ; rep = "" },
        [ordered]@{ org = "[再]" ; rep = "" },
# -replaceで正規表現を使用する場合は、置換対象の文字列をエスケープする必要がありますが、.Replaceを使用する場合は、エスケープは不要です。
#        [ordered]@{ org = "\[字\]" ; rep = "" },   
#        [ordered]@{ org = "\[新\]" ; rep = "" },
#        [ordered]@{ org = "\[SS\]" ; rep = "" },
#        [ordered]@{ org = "\[デ\]" ; rep = "" },
#        [ordered]@{ org = "\[解\]" ; rep = "" },
#        [ordered]@{ org = "\[再\]" ; rep = "" },
        [ordered]@{ org = "アニメ " ; rep = "" },
        [ordered]@{ org = "日5" ; rep = "" },
        [ordered]@{ org = "【アガルアニメ】" ; rep = "" },
        [ordered]@{ org = "【アニメイズム】" ; rep = "" },
        [ordered]@{ org = "【スーパーアニメイズムTURBO】" ; rep = "" },
        [ordered]@{ org = "アニメA・" ; rep = "" },
        [ordered]@{ org = "アニメA " ; rep = "" },
        [ordered]@{ org = "【ヌマニメーション】" ; rep = "" },
        [ordered]@{ org = "【イマニメーション】" ; rep = "" },
        [ordered]@{ org = "【イマニメーション W】" ; rep = "" },
        [ordered]@{ org = "BS11ガンダムアワー " ; rep = "" },   
        [ordered]@{ org = "日曜アニメ劇場" ; rep = "" },
        [ordered]@{ org = "水曜アニメ・水もん " ; rep = "" },
        [ordered]@{ org = "＜アニメギルド＞・" ; rep = "" },
        [ordered]@{ org = "＜アニメギルド＞" ; rep = "" },
        [ordered]@{ org = " FRIDAY ANIME NIGHT" ; rep = "" },
        [ordered]@{ org = "＜ノイタミナ＞" ; rep = "" }
    )) {
        # -replaceは置換対象の文字として英字の大文字と小文字を区別しません。 https://itsakura.com/powershell-replace
        # $fileName = $fileName -replace $replacement.org, $replacement.rep
        # .Replaceは置換対象の文字として英字の大文字と小文字を区別します。
        $fileName = $fileName.Replace($replacement.org, $replacement.rep)
    }
    return $fileName
}

 function Convert-ANiMAZiNGFileName {
# ファイル名を成形(【ANiMAZiNG?!!!】を削除)する関数
    param (
        [string]$fileName
    )
    $firstPosition = $fileName.IndexOf("【ANiMAZiNG")
    if ($firstPosition -ge 0) {
        $secondPosition = $fileName.IndexOf("】", $firstPosition)
        if ($secondPosition -gt $firstPosition) {
            $fileName = $fileName.Remove($firstPosition, $secondPosition - $firstPosition + 1)
        }
    }
    return $fileName
}
