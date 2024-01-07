# Dotfiles

## winget in MS Store:
https://apps.microsoft.com/detail/9NBLGGH4NNS1?rtc=1&hl=en&gl=US

## Set Windows powershell execution policy
```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## Install Chezmoi
```powershell
winget install twpayne.chezmoi
```
## Install Powershell Core
```powershell
winget install Microsoft.Powershell
```

## *Run powershell core as admin*

## Init Chezmoi
```poswershell
chezmoi init stianthaulow --apply
```