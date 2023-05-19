Connect-MsolService

#Install-module Microsoft.Graph.Identity.Signins
Connect-MgGraph -Scopes UserAuthenticationMethod.ReadWrite.All
Select-MgProfile -Name beta


Write-Host "Prehled MFA..."
$Users = Get-MsolUser -all | Where-Object { $_.UserType -ne "Guest" }
$Report = [System.Collections.Generic.List[Object]]::new()
Write-Host "Pocet uzivatel:" $Users.Count
ForEach ($User in $Users) {



        $ReportLine = [PSCustomObject] @{
        Email = $User.UserPrincipalName
        Jmeno = $User.DisplayName
        PocetMFA = (Get-MgUserAuthenticationMethod -UserId $User.UserPrincipalName).count
        MFAHeslo = if( (Get-MgUserAuthenticationPasswordMethod -UserId $User.UserPrincipalName).count -gt 0) { "Ano" } else { "Ne" }
        MFAEmail = if( (Get-MgUserAuthenticationEmailMethod -UserId $User.UserPrincipalName).count -gt 0) { "Ano" } else { "Ne" }
        MFATelefon = if( (Get-MgUserAuthenticationPhoneMethod -UserId $User.UserPrincipalName).count -gt 0) { "Ano" } else { "Ne" }
        MFAMSAuthenticator = if( (Get-MgUserAuthenticationMicrosoftAuthenticatorMethod -UserId $User.UserPrincipalName).count -gt 0) { "Ano" } else { "Ne" }
        MFAFido2 = if( (Get-MgUserAuthenticationFido2Method -UserId $User.UserPrincipalName).count -gt 0) { "Ano" } else { "Ne" }
        MFAPassLess = if( (Get-MgUserAuthenticationPasswordlessMicrosoftAuthenticatorMethod -UserId $User.UserPrincipalName).count -gt 0) { "Ano" } else { "Ne" }


 }

$Report.Add($ReportLine)
}


Write-Host "Vysledek zapsan do c:\temp\MFAUsers.csv"
$Report | Select-Object Email, Jmeno, PocetMFA, MFAHeslo, MFAEmail, MFATelefon, MFAMSAuthenticator , MFAFido2, MFAPassLess | Sort-Object Email | Out-GridView
$Report | Sort-Object Email | Export-CSV -Encoding UTF8 -NoTypeInformation c:\temp\MFAUsers.csv
