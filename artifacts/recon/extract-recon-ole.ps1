$ErrorActionPreference='Stop'
[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new($false)
$root='C:\bitbucket_Automacao\gp-vivo-regressao\artifacts\recon\documents-review'
$out=Join-Path $root '_extracted'
New-Item -ItemType Directory -Path $out -Force | Out-Null
foreach($file in Get-ChildItem -LiteralPath $root -Recurse -File | Where-Object {$_.Extension -eq '.xls'}){
 $connection=[System.Data.OleDb.OleDbConnection]::new("Provider=Microsoft.ACE.OLEDB.12.0;Data Source=$($file.FullName);Extended Properties='Excel 8.0;HDR=NO;IMEX=1'")
 try{
  $connection.Open()
  $schema=$connection.GetSchema('Tables')
  $lines=[System.Collections.Generic.List[string]]::new()
  foreach($tableRow in $schema.Rows){
   $sheet=[string]$tableRow['TABLE_NAME']
   if($tableRow['TABLE_TYPE'] -ne 'TABLE' -or !$sheet.EndsWith("$'")){continue}
   $lines.Add('### Planilha: '+$sheet)
   $command=$connection.CreateCommand()
   $command.CommandText='SELECT * FROM ['+$sheet+']'
   $adapter=[System.Data.OleDb.OleDbDataAdapter]::new($command)
   $table=[System.Data.DataTable]::new()
   [void]$adapter.Fill($table)
   $rowIndex=0
   foreach($row in $table.Rows){
    $rowIndex++
    $parts=[System.Collections.Generic.List[string]]::new()
    for($c=0;$c -lt $table.Columns.Count;$c++){
     if($row.IsNull($c)){continue}
     $value=([string]$row[$c]).Replace("`r",' ').Replace("`n",' ').Trim()
     if($value){$parts.Add(('[{0}] {1}' -f ($c+1),$value))}
    }
    if($parts.Count){$lines.Add(('{0}: {1}' -f $rowIndex,($parts -join ' | ')))}
   }
   $adapter.Dispose();$command.Dispose();$table.Dispose()
  }
  $target=Join-Path $out ($file.BaseName+'.txt')
  [System.IO.File]::WriteAllLines($target,$lines,[System.Text.UTF8Encoding]::new($false))
  Write-Output ("{0}: {1} lines" -f $file.Name,$lines.Count)
 }catch{
  Write-Output ("ERRO {0}: {1}" -f $file.Name,$_.Exception.Message)
 }finally{$connection.Close();$connection.Dispose()}
}
