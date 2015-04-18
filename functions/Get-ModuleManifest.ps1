function Get-ModuleManifest {
    <#
    .SYNOPSIS

    Returns the manifest datas of a module manifest psd1 file.

    .DESCRIPTION

    Returns the manifest datas of a module manifest psd1 file.

    .EXAMPLE

    Get-ModuleManifest C:\packages\myapp.psd1

    #>
    [CmdletBinding()]
    Param
    (
        # Specifies the nuspec files to update
        [ValidateScript( { Test-Path($_) -PathType Leaf -Include *.psd1 } )]
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true )]
        $Path
    )

    if ([System.IO.Path]::IsPathRooted($Path)) {
        $AbsPath = $Path
    } else {
        $AbsPath = Join-Path (Get-Location) $Path
    }

    # load it into an XML object:
    $psd1 = (Get-Content -Raw $AbsPath) | iex
    $psd1

}