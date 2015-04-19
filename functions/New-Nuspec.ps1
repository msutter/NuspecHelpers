function New-Nuspec {
<#
.SYNOPSIS

Creates a nuspec file.

.DESCRIPTION

Creates a nuspec file.

Note: frameworkAssemblies, developmentDependency and references not implemented.

.EXAMPLE

New-Nuspec C:\packages\myapp.nuspec

Creates the given nuspec file with provided parameters.

#>
[CmdletBinding()]
Param
(

  # Specifies the nuspec files to update
  [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true )]
  $Path,

  # Specifies the id
  [Parameter(Mandatory = $true)]
  [string] $id,

  # Specifies the version
  [Parameter(Mandatory = $false)]
  [string] $version,

  # Specifies the titleversion
  [Parameter(Mandatory = $false)]
  [string] $title,

  # Specifies the authors
  [Parameter(Mandatory = $false)]
  [string] $authors,

  # Specifies the owners
  [Parameter(Mandatory = $false)]
  [string] $owners,

  # Specifies the description
  [Parameter(Mandatory = $false)]
  [string] $description,

  # Specifies the releaseNotes
  [Parameter(Mandatory = $false)]
  [string] $releaseNotes,

  # Specifies the summary
  [Parameter(Mandatory = $false)]
  [string] $summary,

  # Specifies the language
  [Parameter(Mandatory = $false)]
  [string] $language,

  # Specifies the projectUrl
  [Parameter(Mandatory = $false)]
  [string] $projectUrl,

  # Specifies the iconUrl
  [Parameter(Mandatory = $false)]
  [string] $iconUrl,

  # Specifies the licenseUrl
  [Parameter(Mandatory = $false)]
  [string] $licenseUrl,

  # Specifies the copyright
  [Parameter(Mandatory = $false)]
  [string] $copyright,

  # Specifies the requireLicenseAcceptance
  [Parameter(Mandatory = $false)]
  [string] $requireLicenseAcceptance,

  # Specifies the tags
  [Parameter(Mandatory = $false)]
  [string] $tags,

  # Specifies the dependencies
  [Parameter(Mandatory = $false)]
  [hashtable[]] $dependencies,

  # Specifies the files
  [Parameter(Mandatory = $false)]
  [hashtable[]] $files

)

  # Set absolute path
  if ([System.IO.Path]::IsPathRooted($Path)) {
      $AbsPath = $Path
  } else {
      $AbsPath = Join-Path (Get-Location) $Path
  }

  # Create the base xml files
  [xml]$NuspecXml = New-Object system.Xml.XmlDocument
  $null = $NuspecXml.LoadXml("<package xmlns=`"http://schemas.microsoft.com/packaging/2010/07/nuspec.xsd`"><metadata></metadata></package>")

  # Set up formatting
  $xmlSettings = new-object System.Xml.XmlWriterSettings
  $xmlSettings.Indent = $true
  $xmlSettings.NewLineOnAttributes = $false

  # Create an XmlWriter and save the modified XML document
  $xmlWriter = [Xml.XmlWriter]::Create($AbsPath, $xmlSettings)
  $null = $NuspecXml.Save($xmlWriter)
  $null = $xmlWriter.Close()

  # Update Nuspec file with provided params
  $null = Update-Nuspec @PSBoundParameters

}