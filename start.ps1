if (-not (Test-Path Env:AZP_URL)) {
    Write-Error "error: missing AZP_URL environment variable"
    exit 1
  }
     
  if (-not (Test-Path Env:AZP_TOKEN_FILE)) {
    if (-not (Test-Path Env:AZP_TOKEN)) {
      Write-Error "error: missing AZP_TOKEN environment variable"
      exit 1
    }
  
    $Env:AZP_TOKEN_FILE = "\azp\.token"
    $Env:AZP_TOKEN | Out-File -FilePath $Env:AZP_TOKEN_FILE
  }
     
  Remove-Item Env:AZP_TOKEN
     
     
  if ($Env:AZP_WORK -and -not (Test-Path $Env:AZP_WORK)) {
    New-Item $Env:AZP_WORK -ItemType directory | Out-Null
  }
     
  $azpPool = "$(if (Test-Path Env:AZP_POOL) { ${Env:AZP_POOL} } else { 'Default' })"
  
  $azpAgentName = "$(if (Test-Path Env:AZP_AGENT_NAME) { ${Env:AZP_AGENT_NAME} } else { ${Env:computername} })"
  
  if (-not (Test-Path "\azp\agent")) {
      New-Item "\azp\agent" -ItemType directory | Out-Null
  }
      
  # Let the agent ignore the token env variables
  $Env:VSO_AGENT_IGNORE = "AZP_TOKEN,AZP_TOKEN_FILE"
      
  Set-Location agent
     
  $azpToken = "$(Get-Content ${Env:AZP_TOKEN_FILE})"
  
  function SetupAgent
  {
      Write-Host "1. Getting Current Agents" -ForegroundColor Cyan
  
      $currentDate = (Get-Date).ToString('MMddyyyyhhmmssffff')
  
      $azpAgentName = "$azpAgentName-$currentDate"
  
      Write-Host "2. Configuring Azure Pipelines agent: $azpAgentName" -ForegroundColor Cyan
  
      .\config.cmd --unattended `
          --agent "$azpAgentName" `
          --url "$(${Env:AZP_URL})" `
          --auth PAT `
          --token "$azpToken" `
          --pool "$azpPool" `
          --work "$(if (Test-Path Env:AZP_WORK) { ${Env:AZP_WORK} } else { '_work' })" `
          --replace
  
      Write-Host "3. Running Azure Pipelines agent..." -ForegroundColor Cyan
  
      .\run.cmd
  
  }    
  
  try
  {
      SetupAgent     
  }
  finally
  {
    Write-Host "4. Cleanup. Removing Azure Pipelines agent..." -ForegroundColor Cyan
    
    .\config.cmd remove --unattended `
      --auth PAT `
      --token "$azpToken"
  }