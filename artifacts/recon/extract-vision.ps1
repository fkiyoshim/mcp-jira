Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::OpenRead('C:\Users\fkiyoshi\Downloads\GP-Visao-Recon-Claro_0101 (1).docx')
try {
  $reader = [System.IO.StreamReader]::new($zip.GetEntry('word/document.xml').Open())
  [xml]$doc = $reader.ReadToEnd()
  $reader.Dispose()
  $ns = [System.Xml.XmlNamespaceManager]::new($doc.NameTable)
  $ns.AddNamespace('w','http://schemas.openxmlformats.org/wordprocessingml/2006/main')
  $lines = foreach ($node in $doc.SelectSingleNode('//w:body',$ns).SelectNodes('.//w:p[not(ancestor::w:tbl)] | .//w:tbl[not(ancestor::w:tbl)]',$ns)) {
    if ($node.LocalName -eq 'tbl') {
      foreach ($row in $node.SelectNodes('./w:tr',$ns)) {
        $cells = foreach ($cell in $row.SelectNodes('./w:tc',$ns)) {
          (($cell.SelectNodes('.//w:p',$ns) | ForEach-Object { ($_.SelectNodes('.//w:t',$ns) | ForEach-Object { $_.InnerText }) -join '' }) -join ' / ')
        }
        $cells -join ' | '
      }
    } elseif ($node.LocalName -eq 'p') {
      ($node.SelectNodes('.//w:t',$ns) | ForEach-Object { $_.InnerText }) -join ''
    }
  }
  $lines | Where-Object { $_.Trim() } | Set-Content -Encoding UTF8 -LiteralPath (Join-Path $PSScriptRoot 'vision-extracted.txt')
} finally { $zip.Dispose() }
