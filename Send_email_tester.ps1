if ((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null) {
    Add-PSSnapin "Microsoft.SharePoint.PowerShell"
}

Write-Host $Host.Version

<#
$currentDate = (Get-Date).Date
Write-Host $currentDate
$endDate = Get-Date -Date 2016-06-08
Write-Host $endDate.Date

if ($endDate.Date -ge $currentDate)
{
    Write-Host "OK"
}
else 
{
    Write-Host "NOT OK"
}
#>

#$myDate = (Get-Date).Date
#Write-Host $myDate

<#
$currentDateNoTime = New-Object "System.DateTime" - (Get-Date).Year, (Get-Date).Month, (Get-Date).Day
Write-Host $currentDateNoTime
$endDateNoTime = New-Object "System.DateTime" - (2016-06-08).Year, (2016-06-08).Month, (2016-06-08).Day
Write-Host $endDateNoTime

if ($endDateNoTime -ge $currentDateNoTime)
{
    Write-Host "OK"
}
else 
{
    Write-Host "NOT OK"
}
#>

<#
Write-Host "Αποστολή email http kai SPS_notifications (original way)"
$smtpServer = "10.29.23.50" 
$msg = new-object Net.Mail.MailMessage
$smtp = new-object Net.Mail.SmtpClient($smtpServer)
$msg.From = "SPS_notifications@alpha.gr"
$msg.To.Add("serafeim.kroustallis@alpha.gr")
$msg.Subject = "original way SPS_notifications"
$msg.Body = "send with original way SPS_notifications"
$smtp.Send($msg)
Write-Host "Αποστολή email http kai SPS_notifications (original way) ολοκληρώθηκε"

Write-Host "Αποστολή email http kai dms_admin (original way)"
$smtpServer = "10.29.23.50" 
$msg = new-object Net.Mail.MailMessage
$smtp = new-object Net.Mail.SmtpClient($smtpServer)
$msg.From = "dms_admin@alpha.gr"
$msg.To.Add("serafeim.kroustallis@alpha.gr")
$msg.Subject = "original way dms_admin"
$msg.Body = "send with original way dms_admin"
$smtp.Send($msg)
Write-Host "Αποστολή email http kai dms_admin (original way) ολοκληρώθηκε"


Write-Host "Αποστολή email http kai SPS_notifications"
$SMTPServer = "10.29.23.50" #"10.12.77.234"
$SMTPClient = New-Object Net.Mail.SmtpClient($SMTPServer)
                
$EmailFrom = "SPS_notifications@alpha.gr"
$EmailTo = "serafeim.kroustallis@alpha.gr"
$Subject = "Test me http kai SPS_notifications"
$Body = "this is a  test with http kai SPS_notifications"
                                                
$SMTPMessage = New-Object System.Net.Mail.MailMessage($EmailFrom,$EmailTo,$Subject,$Body)
$SMTPMessage.IsBodyHtml = $true
                
$SMTPClient.Send($SMTPMessage)
Write-Host "Αποστολή email http kai SPS_notifications ολοκληρώθηκε"


Write-Host "Αποστολή email http kai dms_admin"
$SMTPServer = "10.29.23.50" #"10.12.77.234"
$SMTPClient = New-Object Net.Mail.SmtpClient($SMTPServer)
                
$EmailFrom = "dms_admin@alpha.gr"
$EmailTo = "serafeim.kroustallis@alpha.gr"
$Subject = "Test me http kai dms_admin"
$Body = "this is a  test with http kai dms_admin"
                                                
$SMTPMessage = New-Object System.Net.Mail.MailMessage($EmailFrom,$EmailTo,$Subject,$Body)
$SMTPMessage.IsBodyHtml = $true
                
$SMTPClient.Send($SMTPMessage)
Write-Host "Αποστολή email http kai dms_admin ολοκληρώθηκε"


Write-Host "Αποστολή email https kai SPS_notifications"
$SMTPServer = "10.29.23.50"
$SMTPClient = New-Object Net.Mail.SmtpClient($SMTPServer, 587)
$SMTPClient.EnableSsl = $true 
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential("bank\c20252", "7777mmmm&"); 
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { return $true }
                
$EmailFrom = "SPS_notifications@alpha.gr"
$EmailTo = "serafeim.kroustallis@alpha.gr"
$Subject = "Test me https kai SPS_notifications"
$Body = "this is a  test with https kai SPS_notifications"
                                                
$SMTPMessage = New-Object System.Net.Mail.MailMessage($EmailFrom,$EmailTo,$Subject,$Body)
$SMTPMessage.IsBodyHtml = $true
                
$SMTPClient.Send($SMTPMessage)
Write-Host "Αποστολή email https kai SPS_notifications ολοκληρώθηκε"


Write-Host "Αποστολή email https kai dms_admin"
$SMTPServer = "10.29.23.50"
$SMTPClient = New-Object Net.Mail.SmtpClient($SMTPServer, 587)
$SMTPClient.EnableSsl = $true 
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential("bank\c20252", "7777mmmm&"); 
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { return $true }
                
$EmailFrom = "dms_admin@alpha.gr"
$EmailTo = "serafeim.kroustallis@alpha.gr"
$Subject = "Test me https kai dms_admin"
$Body = "this is a  test with https kai dms_admin"
                                                
$SMTPMessage = New-Object System.Net.Mail.MailMessage($EmailFrom,$EmailTo,$Subject,$Body)
$SMTPMessage.IsBodyHtml = $true
                
$SMTPClient.Send($SMTPMessage)
Write-Host "Αποστολή email https kai dms_admin ολοκληρώθηκε"
#>