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

## *Run powershell as admin*

## Init Chezmoi
```poswershell
chezmoi init stianthaulow --apply
```