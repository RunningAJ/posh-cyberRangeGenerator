function Generate-printers{
<#
.SYNOPSIS
This function will generate printers on a print server. This must be executed from the print server. When executed the script will generate
random printers that are named with a building, room, and printer name. 

.DESCRIPTION

See the example below for proper usage

.EXAMPLE
Generate-printers -numberofprinters 300
#>

param($numberofprinters)
# Generating the building numbers to be used 

$buildings = @()
$brand = @(
'Dell',
'Lexmark',
'HP',
'KM',
'Epson',
'Brother',
'Plotter',
'MFD'
)
foreach ( $i in 1..30 ) { 
$buildingnumber = get-random -Minimum 1000 -Maximum 9999
$buildings += $buildingnumber
}

foreach ( $i in 1..$numberofprinters) { 

$type = Get-Random -InputObject $brand 
$ROOMNUMBER = Get-Random -Minimum 100 -Maximum 1000
$BLDINGNUMBER = Get-Random -InputObject $buildings
$model = Get-Random -Minimum 100 -Maximum 999
add-printer -Name ("BLDNG"+$BLDINGNUMBER+'_RM'+$ROOMNUMBER+'_'+$type+$model).ToString() -DriverName "Dell 1230c Color Laser Printer" -PortName "portprompt:" -sharedname ("BLDNG"+$BLDINGNUMBER+'_RM'+$ROOMNUMBER+'_'+$type+$model).ToString() -shared

}
}  
