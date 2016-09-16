if ((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null) {
    Add-PSSnapin "Microsoft.SharePoint.PowerShell"
}

<#
    1. Check site URL.
    2. Remove TODOs.
    3. Check email settings.
#>
$siteURL = "http://dmsdev2013:81/sites/Contracts"
$currentDate = Get-Date
$logFile = "C:\Temp\Contracts_with_deadline.txt"

Write-Host "Process started"
$currentDate > $logFile

$query = New-Object Microsoft.SharePoint.SPQuery
$query.Query = @"
<Where>
  <And>
    <And>
      <And>
        <Eq>
          <FieldRef Name="IsActive" />
          <Value Type="Boolean">1</Value>
        </Eq>
        <Eq>
          <FieldRef Name="ActiveNotification" />
          <Value Type="Boolean">1</Value>
        </Eq>
      </And>
      <IsNotNull>
        <FieldRef Name="DateEnd" />
      </IsNotNull>
    </And>
    <IsNotNull>
      <FieldRef Name="DateNotifyCount" />
    </IsNotNull>
  </And>
</Where>
<OrderBy>
  <FieldRef Name="BaseId" Ascending="True" />
  <FieldRef Name="ID" Ascending="True" />
</OrderBy>
"@
$query.ViewAttributes = "Scope='RecursiveAll'"


$web = Get-SPWeb -identity $siteURL 
$list = $web.Lists["Συμβάσεις"]
$listItems = $list.GetItems($query)

$listItemsCount = $listItems.Count;
Write-Host "Items: " $listItemsCount

if ($listItemsCount -lt 1) {
     break;
} 
else 
{
    [string]::Format("Items: {0}", $listItemsCount) >> $logFile

	foreach ($item in $listItems)
	{
		#if($item["IsActive"] -eq "Yes" -and $item["ActiveNotification"] -eq "Yes" `
                                       #-and $item["DateEnd"] -ne $null -and $item["DateNotifyCount"] -ne $null) 
        #{
            #Write-Host "Τα βασικά κριτήρια ικανοποιούνται για το " $item["ID"] ".Έλεγχος ημερομηνιών..."
            [string]::Format("Τα βασικά κριτήρια ικανοποιούνται για το {0} .Έλεγχος ημερομηνιών...", $item["ID"]) >> $logFile

            if ($item["DateNotifyCount"] -eq $null)
            {
                #Write-Host "Δεν βρέθηκαν Ημέρες Ειδοποίησης για το " $item["BaseId"]
                [string]::Format("Δεν βρέθηκαν Ημέρες Ειδοποίησης για το {0}", $item["ID"]) >> $logFile
                continue
            }
                        

            $endDate = Get-Date -Date $item["DateEnd"]
            $difference = New-TimeSpan -Start $currentDate -End $endDate
            $realDiff = $difference.Days + 1
            $notificationDays = $item["DateNotifyCount"]
            
            #Write-Host "Διαφορά σε ημέρες:" $realDiff
            [string]::Format("Διαφορά σε ημέρες: {0}", $realDiff) >> $logFile
            #Write-Host "Ημέρες Ειδοποίησης:" $notificationDays
            [string]::Format("Ημέρες Ειδοποίησης: {0}", $notificationDays) >> $logFile

            if ($endDate.Date -ge $currentDate.Date -and ($realDiff -le $notificationDays))
            {
                if ($item["NotificationPersons"] -eq $null)
                {
                    [string]::Format("** Δεν βρέθηκαν πρόσωπα ειδοποίησης για το item: {0}", $item["ID"]) >> $logFile
                }
                else 
                {
                    $emails = @() 
                    foreach($peopleItem in $item["NotificationPersons"]) {
                        $emails += $peopleItem.User.Email
                    }
                    $emails += "serafeim.kroustallis@alphatest.ab"
                 
                    $emailList = [string]::Join(",", $emails)
                    Write-Host "Emails: " $emailList
                    [string]::Format("Emails: {0}", $emailList) >> $logFile
                    
                    $supplier = ""
                    if ($item["Supplier"] -ne $null) {
                        $supplier = $item["Supplier"].Split("#")[1];
                    }
                    
                    try
                    {
                        Write-Host "Αποστολή email για το item" $item["ID"]
                        [string]::Format("Αποστολή email για το item: {0}", $item["ID"]) >> $logFile

                        $symvasiURL = [String]::Format("{0}/Lists/SymvaseisNew/Item/displayifs.aspx?List=f08d3c5c-D2ad4-D409c-D830c-D0da2586cf809&ID={1}&Source={0}/Lists/SymvaseisNew/Custom3.aspx&ContentTypeId=0x0100FF84D28F30883D4CAEC9226D8358AC74", $siteURL, $item["ID"])
                        $linkToSymvasi = [String]::Format("<a href={0}>{1}</a>", $symvasiURL, $item["Title"])

                        $SMTPServer = "10.12.77.234"
                        $SMTPClient = New-Object Net.Mail.SmtpClient($SMTPServer, 587)

                        $SMTPMessage = new-object Net.Mail.MailMessage
                        $SMTPMessage.IsBodyHtml = $true
                        $SMTPMessage.From = "serafeim.kroustallis@alphatest.ab"
                        $SMTPMessage.To.Add([String]::Format("{0}", $emailList)) # "serafeim.kroustallis@alphatest.ab,nikolaos.klavdianos@alphatest.ab"
                        $SMTPMessage.Subject = [String]::Format("Ειδοποίηση για τη σύμβαση(NEW): {0}", $item["MyId"])
                        $SMTPMessage.Body = [String]::Format("<b>ΕΙΔΟΠΟΙΗΣΗ</b></br></br>Η Σύμβαση του <b>Προμηθευτή</b> {0} με το <b>Αντικείμενο Συμβάσεως</b> {1}, <b>Κωδικό Συμβάσεως</b> {2} και <b>Αριθμό Συμβάσεως SAP</b> {3} ανανεώνεται αυτόματα ή λήγει την <b>ημερομηνία</b> {4} </br></br> Παρακαλούμε για τις ενέργειές σας.", $supplier, $linkToSymvasi, $item["MyId"], $item["ContractCodeSAP"], $item["DateEnd"].ToShortDateString())
                
                        $SMTPClient.EnableSsl = $true 
                        $SMTPClient.Credentials = New-Object System.Net.NetworkCredential("banktest\c20252", "20252"); 
                        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { return $true }

                        $SMTPClient.Send($SMTPMessage)
                        Write-Host "Αποστολή email για το item" $item["ID"] "ολοκληρώθηκε"
                        [string]::Format("Αποστολή email για το item: {0} ολοκληρώθηκε", $item["ID"]) >> $logFile
                    }
                    catch [Exception]
                    {
                        [string]::Format("Λάθος κατά την αποστολή email για το item: {0}, Error: {1} ", $item["ID"], $_.Exception.Message) >> $logFile
                    }
                }
		    }
	    #}
    }
}

$web.Dispose();
Write-Host "Process finished"
