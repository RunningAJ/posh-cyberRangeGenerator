function Generate-ComputerAccounts{
<#
.SYNOPSIS
This function will generate computers accounts within active directory. If you want to change the prefix name of these computers please look in the 
$computertpye variable and change the prefix name array.

.DESCRIPTION

See the example below for proper usage

.EXAMPLE
Generate-ComputerAccounts -numberofcomputers 5000
#>

param($numberofcomputers)
$OU = Get-ADOrganizationalUnit -Filter * | where-object Name -CMatch 'Computers' | Select-Object $DistinguishedName -ExpandProperty $DistinguishedName

function Generate-randomcomputername(){
$computertype = @('icsnb','icswk','icstb','icsph','icssvr')
$computerpool = @('0','1','2','3','5','6','7','8','9','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z')
$computerprefix = Get-Random -InputObject $computertype
$generateanumber0 = Get-Random -InputObject $computerpool
$generateanumber1 = Get-Random -InputObject $computerpool
$generateanumber2 = Get-Random -InputObject $computerpool
$generateanumber3 = Get-Random -InputObject $computerpool
$generateanumber4 = Get-Random -InputObject $computerpool
$generateanumber5 = Get-Random -InputObject $computerpool
$generateanumber6 = Get-Random -InputObject $computerpool
$computername = $computerprefix+'-'+$generateanumber0+$generateanumber1+$generateanumber2+$generateanumber3+$generateanumber4+$generateanumber5+$generateanumber6
return $computername
}

foreach ($i in 1..$numberofcomputers){

$path = get-random -InputObject $OU
$name = Generate-randomcomputername
New-ADComputer -Name $name -SAMAccountName $name -Path $path
}
}
