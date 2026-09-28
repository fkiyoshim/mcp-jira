[CmdletBinding()]
param()

$secureToken = Read-Host "Cole o Personal Access Token do Jira" -AsSecureString
$tokenPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureToken)

try {
    $plainToken = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($tokenPointer)
    if ([string]::IsNullOrWhiteSpace($plainToken)) {
        throw "O token nao pode ficar vazio."
    }

    [Environment]::SetEnvironmentVariable("JIRA_TOKEN", $plainToken, "User")
    Write-Host "JIRA_TOKEN configurada com sucesso para o usuario atual."
    Write-Host "Reinicie o Codex ou a extensao da IDE para carregar a variavel."
}
finally {
    if ($null -ne $tokenPointer -and $tokenPointer -ne [IntPtr]::Zero) {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($tokenPointer)
    }
    $plainToken = $null
}

