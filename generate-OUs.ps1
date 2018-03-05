function Generate-OUs{

<#
.SYNOPSIS
This function will generate random OUs in a domain. The first ou it generates is an OU named after the company name you put in. The sub OU's are then created
based on the number of OU's you selected to create. Per each sub-OU created, another three sub-OUs are created containing computers, accounts, groups.

structure

Domain >
    computer name OU > 
        Random OU name >
            accounts 
            computers
            groups


.DESCRIPTION

See the example below for proper usage

.EXAMPLE
Generate-OUs -numberofOUs 20 -companyname MediaPlay
#>
param($numberofOUs,$companyname)

# List of Random OU Names
$officebranch = @(
"Accounting",
"Services",
"Procurement",
"Administration",
"QualityAssurance",
"Operations",
"Staff",
"IT",
"Test",
"Receptions",
"Finance",
"Marketing",
"Training",
"Payroll",
"Solutions",
"Programs",
"Security",
"Research",
"Directives",
"Implementation",
"Integration",
"IncidentResponse",
"Tactics",
"Management",
"Operations",
"Infrastructure",
"Communications",
"Design",
"Quality",
"Assurance",
"Data",
"Plant",
"Machine",
"Civil",
"Electrical",
"Maintenance"
)

#Now creating the first OU underneath the domain
New-ADOrganizationalUnit -Name $companyname
# Getting the location of that OU
$OU = Get-ADOrganizationalUnit -Filter * | where-object Name -EQ $companyname | Select-Object $DistinguishedName -ExpandProperty $DistinguishedName

#Now select random names form the list
$OUNAMES = Get-Random -InputObject $officebranch -Count $numberofOUs

# Now generating OUs based on the randomly select input
foreach ( $i in $OUNAMES ) {
New-ADOrganizationalUnit -Name $i -Path $OU 
$SUBOU = Get-ADOrganizationalUnit -Filter * | Where-Object Name -EQ $i | Select-Object $DistinguishedName -ExpandProperty $DistinguishedName
#Now creating the SUB-OUs from the OU that was just created. 
New-ADOrganizationalUnit -Name "Accounts" -Path $SUBOU
New-ADOrganizationalUnit -Name "Computers" -Path $SUBOU
New-ADOrganizationalUnit -Name "Groups" -Path $SUBOU
}
}
