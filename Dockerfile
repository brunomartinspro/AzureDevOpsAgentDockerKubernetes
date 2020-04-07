FROM mcr.microsoft.com/windows/servercore:ltsc2019
  
WORKDIR /azp
      
run mkdir agent

COPY Dependencies\\agent.zip agent

RUN powershell expand-archive -path .\agent\agent.zip -destinationpath .\agent

RUN powershell Remove-Item .\agent\agent.zip

COPY start.ps1 .
COPY stop.ps1 .

CMD powershell .\start.ps1