$ErrorActionPreference='Stop'
$root='C:\bitbucket_Automacao\gp-vivo-regressao\artifacts\recon\documents-review'
$out=Join-Path $root '_extracted'
New-Item -ItemType Directory -Path $out -Force | Out-Null
$excel=New-Object -ComObject Excel.Application
$excel.Visible=$false
$excel.DisplayAlerts=$false
$excel.AskToUpdateLinks=$false
$excel.AutomationSecurity=3
try{
  foreach($file in Get-ChildItem -LiteralPath $root -Recurse -File | Where-Object {$_.Extension -eq '.xls'}){
    $workbook=$null
    try{
      $workbook=$excel.Workbooks.Open($file.FullName,0,$true)
      $lines=[System.Collections.Generic.List[string]]::new()
      foreach($sheet in $workbook.Worksheets){
        $used=$sheet.UsedRange
        $rows=[Math]::Min([int]$used.Rows.Count,5000)
        $cols=[Math]::Min([int]$used.Columns.Count,150)
        $lines.Add('### Planilha: '+$sheet.Name)
        $values=$used.Value2
        for($r=1;$r -le $rows;$r++){
          $parts=[System.Collections.Generic.List[string]]::new()
          for($c=1;$c -le $cols;$c++){
            $value=if($values -is [System.Array]){$values.GetValue($r,$c)}elseif($r -eq 1 -and $c -eq 1){$values}else{$null}
            if($null -ne $value){
              $v=([string]$value).Replace("`r",' ').Replace("`n",' ').Trim()
              if($v){$parts.Add(('[{0}] {1}' -f ($used.Column+$c-1),$v))}
            }
          }
          if($parts.Count){$lines.Add(('{0}: {1}' -f ($used.Row+$r-1),($parts -join ' | ')))}
        }
        if($used.Rows.Count -gt $rows -or $used.Columns.Count -gt $cols){$lines.Add(('TRUNCADO: dimensões {0}x{1}' -f $used.Rows.Count,$used.Columns.Count))}
      }
      $target=Join-Path $out ($file.BaseName+'.txt')
      [System.IO.File]::WriteAllLines($target,$lines,[System.Text.UTF8Encoding]::new($false))
      Write-Output ("{0}: {1} lines" -f $file.Name,$lines.Count)
    }catch{
      Write-Output ("ERRO {0}: {1}" -f $file.Name,$_.Exception.Message)
    }finally{
      if($workbook){$workbook.Close($false);[void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($workbook)}
    }
  }
}finally{
  $excel.Quit()
  [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($excel)
  [GC]::Collect();[GC]::WaitForPendingFinalizers()
}
