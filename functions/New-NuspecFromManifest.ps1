function New-NuspecFromModule {
<#
.SYNOPSIS

Creates a nuspec file from a Module Manifest.

.DESCRIPTION

Creates a nuspec file from a Module Manifest.

Note: frameworkAssemblies, developmentDependency and references not implemented.

.EXAMPLE

New-NuspecFromManifest C:\packages\myapp.nuspec C:\modules\myapp.psd1

#>
[CmdletBinding()]
Param
(
  # Specifies the module manifest files to load
  [ValidateScript( { Test-Path($_) -PathType Container } )]
  [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true )]
  $ModulePath,

  # Specifies the nupkg files to update
  [ValidateScript( { Test-Path($_) -PathType Container } )]
  [Parameter(Mandatory = $false, Position = 1, ValueFromPipeline = $true )]
  [string]$OutputDirectory,

  # Specify the files to exclude
  [Parameter(Mandatory = $false, Position = 2, ValueFromPipeline = $true )]
  $FileExclude = "tools\**;**\*.Psake.ps1;**\*.Psake.psm1;**\*.Tests.ps1;**\*.Tests.psm1"

)

  # Set manifest absolute path
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

  $Manifest = Get-ModuleManifest $ModuleManifestPath

  $NuspecFileName = "$($Manifest.Name).nuspec"

  # Set nuspec absolute path
  if ([System.IO.Path]::IsPathRooted($OutputDirectory)) {
      $AbsNuspecPath = "${OutputDirectory}\${NuspecFileName}"
  } else {
      $AbsNuspecPath = (Join-Path (Get-Location) "${OutputDirectory}\${NuspecFileName}" )
  }

  $Dependencies = @()
  Foreach ($RequiredModule in $Manifest.RequiredModules) {
    $Dep = @{}
    # if ($RequiredModule.Name) { $Dep.Add('id', $RequiredModule.Name )}
    # if ($RequiredModule.Version) { $Dep.Add('version', $RequiredModule.Name )}
    $null = $Dep.Add('id', $RequiredModule )
    $Dependencies += $Dep
  }

  $NuspecFiles = @()

  # Add all module files
  $NuspecFiles += @{
    src     = '**';
    exclude = $FileExclude
  }

  # Init nuspec params
  $NuspecParams = @{}

  $null = $NuspecParams.Add('id', $Manifest.Name )
  $null = $NuspecParams.Add('tags', (@('powershell','module',"$($Manifest.Name)") -Join " "))

  if ($Manifest.Description) {
   $null = $NuspecParams.Add('description', $Manifest.Description )
  } else {
   $null = $NuspecParams.Add('description', $Manifest.Name )
  }

  if ($Manifest.ModuleVersion) { $null = $NuspecParams.Add('version', $Manifest.ModuleVersion )}
  if ($Manifest.Name) { $null = $NuspecParams.Add('title', $Manifest.Name )}
  if ($Manifest.Author) { $null = $NuspecParams.Add('authors', $Manifest.Author )}
  if ($Manifest.CompanyName) { $null = $NuspecParams.Add('owners', $Manifest.CompanyName )}
  if ($Manifest.HelpInfoURI) { $null = $NuspecParams.Add('projectUrl', $Manifest.HelpInfoURI )}
  if ($Manifest.Copyright) { $null = $NuspecParams.Add('copyright', $Manifest.Copyright )}

  $null = $NuspecParams.Add('dependencies', $Dependencies )
  $null = $NuspecParams.Add('files', $NuspecFiles )

  $null = New-Nuspec -Path $AbsNuspecPath @NuspecParams
  $AbsNuspecPath | Resolve-Path
}


