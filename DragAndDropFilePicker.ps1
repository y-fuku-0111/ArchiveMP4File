# ps1ファイルはBOM付のUTF8で保存することを推奨します。BOMなしUTF8で保存した場合、PowerShell ISEやVSCodeのターミナルで日本語が文字化けする可能性があります。
Add-Type -AssemblyName "PresentationFramework"

$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="FilePicker" Height="250" Width="350" AllowDrop="True" Topmost="True">
  <Grid>
    <ListBox Name="FileListBox" AllowDrop="True"/>
    <TextBlock Name="HintText"
               Text="ここにファイルをドラッグ＆ドロップしてください..."
               Foreground="Gray"
               HorizontalAlignment="Center"
               VerticalAlignment="Center"
               IsHitTestVisible="False" />
  </Grid>
</Window>
"@

$reader = [System.Xml.XmlReader]::Create([System.IO.StringReader]$xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)
$fileListBox = $window.FindName("FileListBox")
$files = @()

$fileListBox.Add_DragOver({
  if ($_.Data.GetDataPresent([Windows.DataFormats]::FileDrop)) {
    $_.Effects = [Windows.DragDropEffects]::Copy
  } else {
    $_.Effects = [Windows.DragDropEffects]::None
  }
  $_.Handled = $true
})

$fileListBox.Add_Drop({
  if ($_.Data.GetDataPresent([Windows.DataFormats]::FileDrop)) {
    $script:files = $_.Data.GetData([Windows.DataFormats]::FileDrop)
    #foreach ($file in $script:files) {$fileListBox.Items.Add($file)} #確認用
    $window.Close()
  }
})
$window.ShowDialog() | Out-Null

Write-Host "ドロップされたファイル："
$files

# powershell -NoProfile -ExecutionPolicy Bypass -File "\\tinasha\works\DTV_mp4\vbs\DragAndDropFilePicker.ps1"
