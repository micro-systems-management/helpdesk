#    Copyright (c) Micro Systems Management 2018, 2019, 2020. All rights reserved.
#    
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    Licensed under the GNU-3.0-or-later license. A copy of the
#    GNU General Public License is available in the LICENSE file
#    located in the root of this repository. If not, see
#    <https://www.gnu.org/licenses/>.
#
Add-Type -AssemblyName System.Windows.Forms
$ResultsFile = "$env:USERPROFILE\Desktop\GetSystemDataResults.txt"
$ResultsFileExists = Test-Path $ResultsFile
If ($ResultsFileExists -eq $True) {
    $OneWeek = (Get-Date).AddDays(-7)
    $LastWritten = (Get-Item -Path $ResultsFile -Force).LastWriteTime
    If ($LastWritten -ge $OneWeek) {
        Write-Host "We found a recent output file."
        Write-Host "Loading your recent script results."
        $GetSystemDataResults = [string]::Join("`r`n",(Get-Content -Path "$ResultsFile"))
        [System.Windows.Forms.Messagebox]::Show($GetSystemDataResults)
        Write-Host "Exiting the routine."
        Exit
    }
    If ($LastWritten -lt $OneWeek) {
        Remove-Item -Path $ResultsFile -Force
    }
}

$i=0
$username = $env:USERNAME
$computername = $env:COMPUTERNAME
$privateipaddresses = Get-NetIPAddress | Where-Object {$_.PrefixOrigin -ne "WellKnown"}
$usernamemessage = "Your username is $username"
$computernamemessage = "Your computername is $computername"
$privateipaddressesmessage =
    foreach ($privateipaddress in $privateipaddresses) {
        $privateipaddressdata = ($privateipaddress.IPAddress)
        $PrefixOrigin = ($privateipaddress.PrefixOrigin).ToString().ToUpper()
        If ($PrefixOrigin -eq 'MANUAL') {
            $PrefixOrigin = "STATIC"
        }
        $i++
        Write-Output "Private IP $i - $privateipaddressdata (this is a $PrefixOrigin IP address)"
    }

$helpdeskmessage = "Please call Micro Systems Management and provide the displayed information to them."

$publicipquerylist = @("http://ipinfo.io/ip", "http://ifconfig.me/ip", "http://icanhazip.com", "http://ident.me", "http://smart-ip.net/myip")

Foreach ($externalserver in $publicipquerylist) {
    $publicipquerylistserver = $publicipquerylist[$i2++]
    Write-Host "Trying to find your public IP address at $publicipquerylistserver."
    $publicipaddress = (Invoke-WebRequest -Uri $publicipquerylistserver).Content
    If ($publicipaddress -match "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}" ) {
        $publicipaddressmessage =
        Write-Output "Your public IP Address is $publicipaddress"
        break
        }
    If ($publicipaddress -notmatch "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}") {
        Write-Host "We tried server $publicipquerylistserver and the request did not result in a response."
    }
}

$privateipaddressesmessage = $([String]::Join(([Convert]::ToChar(10)).ToString(), $privateipaddressesmessage))

$copyrighttext = [char]0x00A9 + " " + "2018 - 2020 Micro Systems Management."

Set-Content -Path "$ResultsFile" -Value "$usernamemessage`n`n$computernamemessage`n`n$privateipaddressesmessage`n`n$publicipaddressmessage`n`n$helpdeskmessage`n`nYour computer information $copyrighttext"
Attrib +R +H +I "$ResultsFile"

$GetSystemDataResults = [string]::Join("`r`n",(Get-Content -Path "$ResultsFile"))
[System.Windows.Forms.Messagebox]::Show($GetSystemDataResults)


Remove-Variable * -ErrorAction SilentlyContinue
$Error.Clear()