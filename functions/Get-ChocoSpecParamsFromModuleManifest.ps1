function Get-ChocoSpecParamsFromModuleManifest {
<#
.SYNOPSIS

Get chocospec params from module manifest

.DESCRIPTION

Get chocospec params from module manifest

.EXAMPLE

#>
[CmdletBinding()]
Param
(
  # Specifies the module manifest files to load
  [ValidateScript( { Test-Path($_) -PathType Container } )]
  [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true )]
  $ModulePath
)

  # Set manifest absolute path
  if ([System.IO.Path]::IsPathRooted($ModulePath)) {
      $AbsModulePath = $ModulePath
  } else {
      $AbsModulePath = Join-Path (Get-Location) $ModulePath
  }

  $ModuleManifestPath = Get-ModuleManifestPath $AbsModulePath
  $Manifest = Get-ModuleManifest $ModuleManifestPath

  $Dependencies = @()

  Foreach ($RequiredModule in $Manifest.RequiredModules) {
    $Dep = @{}
    $null = $Dep.Add('id', $RequiredModule )
    $Dependencies += $Dep
  }

  # Init chocospec params
  $chocoSpecParams = @{}

  $null = $chocoSpecParams.Add('id', $Manifest.Name )
  $null = $chocoSpecParams.Add('tags', @('powershell','module',"$($Manifest.Name)"))

  if ($Manifest.Description) {
   $null = $chocoSpecParams.Add('description', $Manifest.Description )
  } else {
   $null = $chocoSpecParams.Add('description', $Manifest.Name )
  }

  if ($Manifest.ModuleVersion) { $null = $chocoSpecParams.Add('version', $Manifest.ModuleVersion )}
  if ($Manifest.Name) { $null = $chocoSpecParams.Add('title', $Manifest.Name )}
  if ($Manifest.Author) { $null = $chocoSpecParams.Add('authors', $Manifest.Author )}
  if ($Manifest.CompanyName) { $null = $chocoSpecParams.Add('owners', $Manifest.CompanyName )}
  if ($Manifest.HelpInfoURI) { $null = $chocoSpecParams.Add('projectUrl', $Manifest.HelpInfoURI )}
  if ($Manifest.Copyright) { $null = $chocoSpecParams.Add('copyright', $Manifest.Copyright )}

  $null = $chocoSpecParams.Add('dependencies', $Dependencies )

  return $chocoSpecParams
}


