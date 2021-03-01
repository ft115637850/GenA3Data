param(
    [Parameter(Mandatory = $True)][string] $csvFile,
    [Parameter(Mandatory = $True)][string[]] $teamMembers
)
#$csvFile = "D:\hmi\doc\internal report\test.csv"
#$teamMembers = "Newton Zou", "Steven Zhou", "Tom Weng"


$membersCalc = @{ }
foreach ($m in $teamMembers) {
    $membersCalc.Add($m , [double]0)
}

$calcHours = @{ }
foreach ($m in $calcHours) {
    $calcHours.Add($m , [double]0)
}

$TableData = Import-Csv -Path $csvFile
$lastStoryPoints = [double]0
$lastStoryTotalHours = [double]0
foreach ($DataValue in $TableData) {
    if (-not [string]::IsNullOrEmpty($DataValue.'Story Points')) {
        #if ($DataValue.'Work Item Type' -eq 'User Story' -or  $DataValue.'Work Item Type' -eq 'Bug')
        ##Calculate last one
        if ($lastStoryPoints -ne 0) {
            $teamMembers | ForEach-Object { $membersCalc[$_] += $lastStoryPoints * $calcHours[$_] / $lastStoryTotalHours }
        }
        ##Initialize for new
        $lastStoryPoints = [double]$DataValue.'Story Points'
        $lastStoryTotalHours = [double]0
        $teamMembers | ForEach-Object { $calcHours[$_] = [double]0 }
    }
    else {
        $lastStoryTotalHours += $DataValue.'Completed Work'
        if ($teamMembers -contains $DataValue.'Assigned To') {
            $calcHours[$DataValue.'Assigned To'] += [double]($DataValue.'Completed Work')
        }
    }

}

if ($lastStoryPoints -ne 0) {
    $teamMembers | ForEach-Object { $membersCalc[$_] += $lastStoryPoints * $calcHours[$_] / $lastStoryTotalHours }
}

$membersCalc
