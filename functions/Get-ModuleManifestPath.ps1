function Get-ModuleManifestPath {
    <#
    .SYNOPSIS

    Returns the manifest path (psd1 file) of a module.

    .DESCRIPTION

    Returns the manifest path (psd1 file) of a module.

    .EXAMPLE

    Get-ModuleManifestPath C:\modules\mymodule

    #>
    [CmdletBinding()]
    Param
    (
      # Module path (C:\modules\mymodule)
      [ValidateScript( { Test-Path($_) -PathType Container } )]
      [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true )]
      $ModulePath,
    )

    if ([System.IO.Path]::IsPathRooted($ModulePath)) {
        $AbsModulePath = $ModulePath
    } else {
        $AbsModulePath = Join-Path (Get-Location) $ModulePath
    }

    # Choose correct manifest, prefer manifest with same name as parent folder
    $ModulePSDs = (Get-ChildItem $AbsModulePath -Filter *.psd1).FullName

    if (($ModulePSDs | measure).count -gt 1){

        foreach ($ModulePSD in $ModulePSDs) {
            $ModulePSDFragments = $ModulePSD -split '\\' -split '\.'
            [Array]::Reverse($ModulePSDFragments)
            if ($ModulePSDFragments[1] -like $ModulePSDFragments[2]){
                $ModuleManifestPath = $ModulePSD
                break
            }
        }

        if ($ModuleManifestPath -eq $null){
            throw "Multiple psd1 found, but no match between parent directory and psd1 file name. Ambigious module manifest."
        }

    } else {
        #TODO: For backwards compatibilty allow psd1 which doesn't match the parent directory name.
        $ModuleManifestPath = $ModulePSDs
    }

    return $ModuleManifestPath

}