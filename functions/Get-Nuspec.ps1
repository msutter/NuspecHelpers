function Get-Nuspec {
    <#
    .SYNOPSIS

    Returns the package xml object of a nuspec xml file.

    .DESCRIPTION

    Returns the package xml object of a nuspec xml file.

    .EXAMPLE

    Get-Nuspec C:\packages\myapp.nuspec

    #>
    [CmdletBinding()]
    Param
    (
        # Specifies the nuspec files to update
        [ValidateScript( { Test-Path($_) -PathType Leaf -Include *.nuspec } )]
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true )]
        $Path
    )

    if ([System.IO.Path]::IsPathRooted($Path)) {
        $AbsPath = $Path
    } else {
        $AbsPath = Join-Path (Get-Location) $Path
    }

    # load it into an XML object:
    $NuspecXml = New-Object -TypeName XML
    # $NuspecXml.PreserveWhitespace = $true
    $null = $NuspecXml.Load($AbsPath)

    $NuspecXml

}