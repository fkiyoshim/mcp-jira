$file='C:\bitbucket_Automacao\gp-vivo-regressao\artifacts\recon\documents-review\testes\especificacoes\Recon\RT-ConfigurarReconciliacaoEquipamento.xls'
$connection=[System.Data.OleDb.OleDbConnection]::new("Provider=Microsoft.ACE.OLEDB.12.0;Data Source=$file;Extended Properties='Excel 8.0;HDR=NO;IMEX=1'")
try{
 $connection.Open()
 $schema=$connection.GetSchema('Tables')
 $schema | Select-Object -First 10 TABLE_NAME,TABLE_TYPE | Format-Table -AutoSize
}finally{$connection.Close();$connection.Dispose()}
