<#
.SYNOPSIS
collects account pictures from exchange (onpre or online) and Active Directory and shows them in a window next to each other

.DESCRIPTION
collects account pictures from exchange (onpre or online) and Active Directory and shows them in a window next to each other

.PARAMETER UserPrincipalName
the UPN of the account to check. Accepts SamAccountName, too.

ALIAS: SamAccountName
MANDATORY: yes
PIPELINE: not supported

.EXAMPLE
Compare-UserPhotos einstein

... show the user photos of user einstein

.NOTES
Maximilian Otter, Jan 2010
#>
function Compare-UserPhotos {
    param (
        [Parameter(Mandatory,Position=0)]
        [Alias('SamAccountName')]
        $UserPrincipalName
    )

    # check for correct powershell version
    if ($PSVersionTable.Version.Major -gt 5) {
        Throw 'Powershell Core not supported.'
    }

    # check if the necessary modules/sessions are loaded
    if (!(Get-Command -Name Get-UserPhoto -ErrorAction SilentlyContinue)) {
        Throw 'Exchange cmdlets not available'
    } else {
        if (!(Get-Command -Name Get-ADUser -ErrorAction SilentlyContinue)) {
            Throw 'ActiveDirectory cmdlets not available'
        }
    }

    # make SamAccountName a UserPrincipalName
    if ($UserPrincipalName -notlike '*@*') {
        $DNSRoot = (Get-ADDomain).DNSRoot
        $UserPrincipalName = $UserPrincipalName + '@' + $DNSRoot
    }

    # retreive account pictures
    $ExcPhoto = (Get-UserPhoto $UserPrincipalName).PictureData
    $ADPhoto  = (Get-ADUser ($UserPrincipalName -split '@')[0] -Properties thumbnailPhoto).thumbnailPhoto

    # if at least one photo exists...
    if ($ExcPhoto -or $ADPhoto) {

        # ... prepare windows form for showing pictures in a window
        $null = [Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
        $Form = [Windows.Forms.Form]::new()
        $Form.Text = "Exchange vs AD Picture - $UserPrincipalName"
        $Form.AutoSize = $true
        $Form.AutoSizeMode = 'GrowAndShrink'

        # if there is an exchange photo prepare the picturebox and add it to the form
        if ($ExcPhoto) {
            $ExcPictureBox = [Windows.Forms.PictureBox]::new()
            $ExcPictureBox.SizeMode = 'AutoSize'
            $ExcPictureBox.Image = $ExcPhoto
            Write-Debug "ExcPic: $($ExcPictureBox.Width)x$($ExcPictureBox.Height)"
            $Form.Controls.Add($ExcPictureBox)
        } else {
            Write-Warning 'No Exchange Photo available.'
        }

        # if there is an active directory photo prepare the picture box,
        # place it next to the exchange photo (if present)
        # and add the picturebox to the form
        if ($ADPhoto) {
            $ADPictureBox = [Windows.Forms.PictureBox]::new()
            $ADPictureBox.SizeMode = "AutoSize"
            $ADPictureBox.Image = $ADPhoto
            Write-Debug "ADPic: $($ADPictureBox.Width)x$($ADPictureBox.Height)"
            if ($ExcPhoto) {
                $ADPictureBox.Location = [System.Drawing.Point]::new($ExcPictureBox.Width + 10, 0)
            }
            $Form.Controls.Add($ADPictureBox)
        } else {
            Write-Warning 'No ActiveDirectory Photo available.'
        }

        # show window with pictures
        $Form.Add_Shown({$Form.Activate()})
        $null = $Form.ShowDialog()

    } else {
        Write-Warning 'No photos found.'
    }

}