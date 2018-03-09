function Generate-Groups{
<#
.SYNOPSIS
This function will generate random group names and then add users within these groups on the domain.This script takes a decent amount of time to run.

.DESCRIPTION

See the example below for proper usage

.EXAMPLE
Generate-Groups -numberofgroupstocreate 1000
#>

param($numberofgroupstocreate)

#Importing the name list 

$jobprefix1 = @(
"Lead",
"Senior",
"Direct",
"Corporate",
"Dynamic",
"Future",
"Product",
"National",
"Regional",
"District",
"Central",
"Global",
"Customer",
"Investor",
"Dynamic",
"International",
"Legacy",
"Forward",
"Internal",
"Human",
"Chief",
"Principal",
"Assistant"
)
$jobprefix2 = @(
"Solutions",
"Program",
"Security",
"Research",
"Directives",
"Implementation",
"Integration",
"Functionality",
"Response",
"Paradigm",
"Tactics",
"Identity",
"Group",
"Division",
"Applications",
"Optimization",
"Operations",
"Infrastructure",
"Communications",
"Web",
"Quality",
"Assurance",
"Accounts",
"Data",
"Configuration",
"Accountability",
"Interactions",
"Factors",
"Usability",
"Metrics",
"Dam",
"Plant",
"Machine",
"Water",
"Switchboard",
"CAD",
"Civil",
"Electrical",
"Geotechnical"
)
$jobprefix3 = @(
"Supervisor",
"Associate",
"Executive",
"Liason",
"Officer",
"Manager",
"Engineer",
"Specialist",
"Director",
"Coordinator",
"Administrator",
"Architect",
"Analyst",
"Designer",
"Planner",
"Orchestrator",
"Technician",
"Developer",
"Producer",
"Consultant",
"Assistant",
"Facilitator",
"Agent",
"Representative",
"Strategist",
"Operator"
)
$types = @(
'Operators',
'Members',
'Admins',
'Leads',
'Engineers',
'Staff',
'Planners',
'Controllers',
'Facilitator'
)
$OUs = Get-ADOrganizationalUnit -Filter * | Where-Object Name -CMatch "Groups"


# Now getting ready to create array that will contain all the groups
$count = $numberofgroupstocreate
$GROUPLIST = @()

foreach ( $i in 1..$count ) {
# Now creating the object to add to the array
$grouptype1 = (Get-Random -InputObject $jobprefix2).ToString()
$grouptype2 = (Get-Random -InputObject $types).ToString()
$export = New-Object psobject
$export | Add-Member -Name Name -MemberType NoteProperty -Value "$grouptype1 $grouptype2"
$export | Add-Member -Name SamAccountName -MemberType NoteProperty -Value "$grouptype1.$grouptype2" 
$export | Add-Member -Name Description -MemberType NoteProperty -Value "Members of this group are $grouptype1 $grouptype2"
$GROUPLIST += $export
Write-Output "Now generating group $i out of $count"
}
$GROUPLIST = $GROUPLIST | Sort-Object Name | Get-Unique -AsString
import-module ActiveDirectory
foreach ($i in $GROUPLIST){
$path = get-random -InputObject $OUs | Select-Object $DistinguishedName -ExpandProperty $DistinguishedName
New-ADGroup -Name $i.Name -SamAccountName $i.SamAccountName -Description $i.Description -GroupScope Global -GroupCategory Security -Path $path
}
# Now adding users to these groups 
$users = Get-ADUser -Filter *

foreach ($i in $GROUPLIST) {
$memberstoadd = get-random -Minimum 10 -Maximum 200

foreach ($y in 1..$memberstoadd ) {
$usertoadd = Get-Random -InputObject $users
$usertoadd = $usertoadd.SamAccountName
Add-ADGroupMember -Identity $i.SamAccountName -Members $usertoadd
}
}
}
