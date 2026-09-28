$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$root='C:\bitbucket_Automacao\gp-vivo-regressao\artifacts\recon\documents-review'
$out=Join-Path $root '_extracted'
New-Item -ItemType Directory -Path $out -Force | Out-Null
$manifest=@()
foreach($file in Get-ChildItem -LiteralPath $root -Recurse -File | Where-Object { $_.Extension -in @('.odt','.ods') }){
  $zip=[System.IO.Compression.ZipFile]::OpenRead($file.FullName)
  try{
    $entry=$zip.GetEntry('content.xml')
    if(!$entry){throw "content.xml ausente: $($file.FullName)"}
    $reader=[System.IO.StreamReader]::new($entry.Open())
    try{$content=$reader.ReadToEnd()}finally{$reader.Dispose()}
    $xml=[xml]$content
    $ns=[System.Xml.XmlNamespaceManager]::new($xml.NameTable)
    $ns.AddNamespace('office','urn:oasis:names:tc:opendocument:xmlns:office:1.0')
    $ns.AddNamespace('text','urn:oasis:names:tc:opendocument:xmlns:text:1.0')
    $ns.AddNamespace('table','urn:oasis:names:tc:opendocument:xmlns:table:1.0')
    $lines=[System.Collections.Generic.List[string]]::new()
    if($file.Extension -eq '.odt'){
      foreach($node in $xml.SelectNodes('//office:body/office:text//text:h | //office:body/office:text//text:p',$ns)){
        $v=$node.InnerText.Trim()
        if($v){$prefix=if($node.LocalName -eq 'h'){'# '}else{''};$lines.Add($prefix+$v)}
      }
    }else{
      foreach($sheet in $xml.SelectNodes('//office:body/office:spreadsheet/table:table',$ns)){
        $name=$sheet.GetAttribute('name','urn:oasis:names:tc:opendocument:xmlns:table:1.0')
        $lines.Add('### Planilha: '+$name)
        $rowIndex=0
        foreach($row in $sheet.SelectNodes('./table:table-row',$ns)){
          $rowIndex++
          $parts=[System.Collections.Generic.List[string]]::new()
          $colIndex=0
          foreach($cell in $row.SelectNodes('./table:table-cell | ./table:covered-table-cell',$ns)){
            $colIndex++
            $v=($cell.SelectNodes('.//text:p',$ns) | ForEach-Object {$_.InnerText}) -join ' / '
            $v=$v.Trim()
            if($v){$parts.Add(('[{0}] {1}' -f $colIndex,$v))}
          }
          if($parts.Count){$lines.Add(('{0}: {1}' -f $rowIndex,($parts -join ' | ')))}
        }
      }
    }
    $target=Join-Path $out ($file.BaseName+'.txt')
    [System.IO.File]::WriteAllLines($target,$lines,[System.Text.UTF8Encoding]::new($false))
    $manifest+=@{file=$file.FullName;output=$target;lines=$lines.Count}
  }finally{$zip.Dispose()}
}
$manifest | ConvertTo-Json -Depth 3 | Set-Content -LiteralPath (Join-Path $out 'manifest.json') -Encoding UTF8
$manifest | ForEach-Object {Write-Output ("{0}: {1} lines" -f [System.IO.Path]::GetFileName($_.file),$_.lines)}
