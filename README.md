# PS_Compare-UserPhotos

## Why

I needed a way to quickly compare the photos of my users saved in Active Directory and Exchange (on premises or online).

Compare-UserPhotos does just that. Fetch the pictures and shows them side by side.

## Requirements

* Powershell 5.1
* ActiveDirectory module or imported session (Get-ADUser, Get-ADDomain)
* Exchange Management Console or imported session (Get-UserPhoto)
