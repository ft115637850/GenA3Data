param(
    [Parameter(Mandatory = $True)][string] $csvFile,
    [Parameter(Mandatory = $True)][string[]] $teamMembers
)

$membersCalc = @{ }
$calcHours = @{ }

$TableData = Import-Csv -Path $csvFile
$lastStoryPoints = [double]0
$lastStoryTotalHours = [double]0
foreach ($DataValue in $TableData) {
    if (-not [string]::IsNullOrEmpty($DataValue.'Story Points')) {
        ##Calculate last one
        if ($lastStoryPoints -ne 0 -and $lastStoryTotalHours -ne 0) {
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

if ($lastStoryPoints -ne 0 -and $lastStoryTotalHours -ne 0) {
    $teamMembers | ForEach-Object { $membersCalc[$_] += $lastStoryPoints * $calcHours[$_] / $lastStoryTotalHours }
}

$membersCalc
