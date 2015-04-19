function Confirm-NuspecFilesHashValidity {
    <#
    .SYNOPSIS

    Validates the hashtable for Nuspec files

    .DESCRIPTION

    Validates the hashtable for Nuspec files

    Should be of the form:

    $files = @(¨
        @{
            src='filesrc1\**';
            target='filetarget1\**'
        },
        @{
            src='filesrc2\**';
            target='filetarget2\**'
        }
    )

    .EXAMPLE

    Validate-NuspecFilesHash $files
    #>

    [CmdletBinding()]
    Param
    (
        # Specifies the files hash
        [Parameter(Mandatory = $false)]
        [hashtable[]]$files
    )

    $MandatoryKeys = @('src','target')
    $OptionalKeys = @('exclude')

    $AllowedKeys = $MandatoryKeys + $OptionalKeys

    foreach($file in $files) {

        # Check unallowed keys
        $UnallowedKeys = Compare-Object $AllowedKeys ([Array]$file.keys) |
        Where-Object { $_.SideIndicator -eq '=>' } |
        ForEach-Object {$_.InputObject}

        if ($UnallowedKeys.Count -gt 0) {
            $UnallowedKeys | % { Write-Error "Unallowed key $_ found in the file hashtable" }
            $ValidationError = $true
        }

        # Check missing mandatory keys
        $MissingKeys = Compare-Object $MandatoryKeys ([Array]$file.keys) |
        Where-Object { $_.SideIndicator -eq '<=' } |
        ForEach-Object {$_.InputObject}

        if ($MissingKeys.Count -gt 0) {
            $MissingKeys | % { Write-Error "Mandatory key $_ is missing in the file hashtable" }
            $ValidationError = $true
        }

        if ($ValidationError) { Throw }
    }

}