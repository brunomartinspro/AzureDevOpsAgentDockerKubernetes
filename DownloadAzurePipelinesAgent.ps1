param (
             [Parameter(Mandatory=$true)][String]$AZP_TOKEN,
             [Parameter(Mandatory=$true)][String]$AZP_URL
         )
Write-Host "Determining matching Azure Pipelines agent..." -ForegroundColor Cyan

$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$AZP_TOKEN"))
$package = Invoke-RestMethod -Headers @{Authorization=("Basic $base64AuthInfo")} "$AZP_URL/_apis/distributedtask/packages/agent?platform=win-x64&`$top=1"
$packageUrl = $package[0].Value.downloadUrl

Write-Host $packageUrl

Write-Host "Downloading and installing Azure Pipelines agent..." -ForegroundColor Cyan

New-Item -Path "Dependencies" -ItemType "directory"

$wc = New-Object System.Net.WebClient
$wc.DownloadFile($packageUrl, "$(Get-Location)\Dependencies\agent.zip")