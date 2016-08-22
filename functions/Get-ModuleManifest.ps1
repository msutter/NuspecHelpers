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
        # psd1 file path
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
    $ModuleName = (Get-Item $AbsPath).BaseName

    $ModuleData = (Get-Content -Raw $AbsPath) | iex
    $null = $ModuleData.add('Name',$ModuleName)

    $ModuleData
}