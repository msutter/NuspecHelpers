function Confirm-NuspecHashArrayValidity {
    <#
    .SYNOPSIS

    Validates a hashtable on the required keys

    .DESCRIPTION

    Validates a hashtable on the required keys

    .EXAMPLE

    #>

    [CmdletBinding()]
    Param
    (
        # Specifies the array of hashtables
        [Parameter(Mandatory = $true)]
        [hashtable[]]$HashArray,

        # Specifies the Mandatory Keys
        [Parameter(Mandatory = $true)]
        [array]$MandatoryKeys,

        # Specifies the Optional Keys
        [Parameter(Mandatory = $false)]
        [array]$OptionalKeys=@()

    )

    $AllowedKeys = $MandatoryKeys + $OptionalKeys

    foreach($Hash in $HashArray) {

        # Check unallowed keys
        $UnallowedKeys = Compare-Object $AllowedKeys ([Array]$Hash.keys) |
        Where-Object { $_.SideIndicator -eq '=>' } |
        ForEach-Object {$_.InputObject}

        if ($UnallowedKeys.Count -gt 0) {
            $UnallowedKeys | % { Write-Error "Unallowed key $_ found in the Hash hashtable" }
            $ValidationError = $true
        }

        # Check missing mandatory keys
        $MissingKeys = Compare-Object $MandatoryKeys ([Array]$Hash.keys) |
        Where-Object { $_.SideIndicator -eq '<=' } |
        ForEach-Object {$_.InputObject}

        if ($MissingKeys.Count -gt 0) {
            $MissingKeys | % { Write-Error "Mandatory key $_ is missing in the Hash hashtable" }
            $ValidationError = $true
        }

        if ($ValidationError) { Throw }
    }

}