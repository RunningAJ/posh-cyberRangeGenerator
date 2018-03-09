function Generate-Documents{
<#
.SYNOPSIS
This function will generate files and folders in a folder share. The files are generated using random file sizes, names, and extensions via the fsutil exe. 
The folders and files genearted are than permissioned via AD security groups.Also after the files have been generated, the time stamps are modified to 
randomize the dates. 

FOR THE COMPANYNAME MAKE SURE IT MATCHES AN OU NAME IN ACTIVE DIRECTORY THAT CONTAINS YOUR GROUPS, USERS, AND SUB-OUs.

.DESCRIPTION

See the example below for proper usage

.EXAMPLE
Generate-Documents -numberofdocuments 5000 -sharepath d:\fileshare -companyOUName ICS
#>
param($numberofdocuments,$SharePath,$companyname)
#Generating the folders for this file server based on AD OUs
$mainfolders = Get-ADOrganizationalUnit -Filter * | Where-Object DistinguishedName -CMatch "OU=$companyname"
$mainfolders = $mainfolders | Where-Object Name -ne 'Computers' | Where-Object Name -ne 'Accounts' | Where-Object Name -ne 'Groups' | Select-Object Name -ExpandProperty Name 
$adgroups = Get-ADGroup -Filter * | Where-Object DistinguishedName -CNotMatch 'CN=Users' | Select-Object SamAccountName -ExpandProperty SamAccountName

$randombucket1 = @('2015','2016','2017','2018','2014','2013','2012','2011','2010','Q4','Q3','Q2','Q1','Annual','Semi',
'Quarterly','pay','work','schedule','program','overview','strategy','report','brief','training','class','accounts','payable','award',
'incentive','process','survey','systems','personnel','entry','post','journal','document','conseling','notes','request','operations',
'tracking','phase','plan','memorandum','memo','agreement','tps report','mission','service','staff','estimate','tactical','annual','audit',
'inspections','compliace','leave','vacation','policy','scenario','guide','continued','public','affairs','packet','daily','hourly',
'reference','scanned','image','contract','meeting','agenda','FY','EOY','ROI','CAPEX','version','handbook','duties','coverage','running','instructions','kits'
'equipment','payable','employess','recruit','hire','applicant','manual','diagram','SOP','request','facility','task','project','roster','phone','email','security','clearance','roster'
)


function Generate-FileName{
$extensions = @('.jpg','.pdf','.doc','.docx','.xls','.xlsx','.ppt','.pptx','.txt','.csv','.tif','.gif','.xml','.png','.db','.bmp','.zip','.avi','.mp3','.mpeg','.jpeg')
$randombucket2 = @('2015','2016','2017','2018','2014','2013','2012','2011','2010','Q4','Q3','Q2','Q1','Annual','Semi',
'Quarterly','pay','work','schedule','program','overview','strategy','report','brief','training','class','accounts','payable','award',
'incentive','process','survey','systems','personnel','entry','post','journal','document','conseling','notes','request','operations',
'tracking','phase','plan','memorandum','memo','agreement','tps report','mission','service','staff','estimate','tactical','annual','audit',
'inspections','compliace','leave','vacation','policy','scenario','guide','continued','public','affairs','packet','daily','hourly',
'reference','scanned','image','contract','meeting','agenda','FY','EOY','ROI','CAPEX','version','handbook','duties','coverage','running','instructions','kits'
'equipment','payable','employess','recruit','hire','applicant','manual','diagram','SOP','request','facility','task','project','roster','phone','email','security','clearance','roster'
)
$statement = Get-Random -Minimum 0 -Maximum 2
if ($statement -eq 0) {$filename = (Get-Random -InputObject $randombucket2)+' '+(Get-Random -InputObject $randombucket2)+' '+(Get-Random -InputObject $randombucket2)+(get-random -InputObject $extensions) } else { $filename = (Get-Random -InputObject $randombucket2)+' '+(Get-Random -InputObject $randombucket2)+(get-random -InputObject $extensions)}
return $filename
}


foreach ($i in $mainfolders ){
New-Item -Name $i -Path $SharePath -ItemType Directory
$subdir = (Get-Item -Path "$SharePath\$i" ).FullName

$subfolders = Get-ADGroup -Filter * -Properties CN | Where-Object DistinguishedName -CMatch "OU=Groups,OU=$i"
foreach ($y in $subfolders){
$username = $y.samaccountname
New-Item -Name $y.cn -Path $subdir -ItemType Directory
# Now setting the permissions on that folder for administrators, fileadmins, and the specifc security group
$path = Get-Item -Path "$subdir\$($y.cn)"
$acl = (get-item $path).GetAccessControl('Access')
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username,'Modify','ContainerInherit,ObjectInherit','None','Allow')
$acl.SetAccessRule($Ar)
Set-Acl -Path $path -AclObject $acl
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule('Administrators','FullControl','ContainerInherit,ObjectInherit','None','Allow')
$acl.SetAccessRule($Ar)
Set-Acl -Path $path -AclObject $acl
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule('FileAdmins','FullControl','ContainerInherit,ObjectInherit','None','Allow')
$acl.SetAccessRule($Ar)
Set-Acl -Path $path -AclObject $acl
$acl.SetAccessRuleProtection($true,$false)
Set-Acl -Path $path -AclObject $acl
# Now creating the subfolders within those folders
$folderstocreate = get-random -Minimum 5 -Maximum 30
foreach($r in 1..$folderstocreate){
New-Item -Name ((Get-Random -InputObject $randombucket1)+(Get-Random -InputObject $randombucket1)) -Path $path -ItemType Directory
}
}
}

$folders = Get-ChildItem -Path $SharePath -Recurse | where-object Attributes -EQ Directory

foreach ($t in 1..$numberofdocuments){
$path = Get-Random -InputObject $folders
$filename = generate-filename
$size = get-random -Minimum 10000 -Maximum 100000
fsutil.exe file createnew "$($path.FullName)\$filename" $size
}

#now changing the time stamps on all documents to different days

$AllFiles = Get-ChildItem -Path $SharePath -Recurse
[DateTime]$min = [DateTime]"1/1/2000"
[DateTime]$max = [datetime]::Now
foreach ( $y in $AllFiles ){
[DateTime]$date = Get-Random -Minimum $min.Ticks -Maximum $max.Ticks
$y | ForEach-Object {
$_.CreationTime = $date
$_.LastAccessTime = $date
$_.LastWriteTime = $date
}
}
}
