function Update-Nuspec {
<#
.SYNOPSIS

Updates a nuspec file.

.DESCRIPTION

Updates a nuspec file.
Values will be overwritten

.EXAMPLE

Update-Nuspec C:\packages\myapp.nuspec

Updates the given nuspec file with provided parameters.

#>
[CmdletBinding()]
Param
(

  # Specifies the nuspec files to update
  [ValidateScript( { Test-Path($_) -PathType Leaf -Include *.nuspec } )]
  [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true )]
  $Path,

  # Specifies the id
  [Parameter(Mandatory = $false)]
  [string] $id,

  # Specifies the version
  [Parameter(Mandatory = $false)]
  [string] $version,

  # Specifies the authors
  [Parameter(Mandatory = $false)]
  [string] $authors,

  # Specifies the owners
  [Parameter(Mandatory = $false)]
  [string] $owners,

  # Specifies the projectUrl
  [Parameter(Mandatory = $false)]
  [string] $projectUrl,

  # Specifies the requireLicenseAcceptance
  [Parameter(Mandatory = $false)]
  [string] $requireLicenseAcceptance,

  # Specifies the description
  [Parameter(Mandatory = $false)]
  [string] $description,

  # Specifies the copyright
  [Parameter(Mandatory = $false)]
  [string] $copyright,

  # Specifies the tags
  [Parameter(Mandatory = $false)]
  [string[]] $tags,

  # Specifies the dependencies
  [Parameter(Mandatory = $false)]
  [hashtable[]] $dependencies,

  # Specifies the files
  [Parameter(Mandatory = $false)]
  [hashtable[]] $files,

  # Specifies the Replace
  [Parameter(Mandatory = $false)]
  [switch] $Overwrite
)



  $MetadataParams = @(
    'id',
    'version',
    'authors',
    'owners',
    'projectUrl',
    'requireLicenseAcceptance',
    'description',
    'copyright',
    'tags',
    'dependencies'
  )

  # Set absolute path
  if ([System.IO.Path]::IsPathRooted($Path)) {
      $AbsPath = $Path
  } else {
      $AbsPath = Join-Path (Get-Location) $Path
  }

  # Load Nuspec file
  $NuspecXml = Get-Nuspec $AbsPath
  $xmlns = $NuspecXml.DocumentElement.NamespaceURI

  # Update metadata values
  foreach ($ParamKey in $MetadataParams ) {
    if ($PSBoundParameters.ContainsKey($ParamKey)) {
      $NuspecXml.package.metadata.${ParamKey} = $PSBoundParameters.${ParamKey}
    }
  }

  # Update Files
  if ($PSBoundParameters.ContainsKey('files')) {

    Confirm-NuspecFilesHashValidity $files

    if ($Overwrite) {
      # clean files
      $xmlfiles = $NuspecXml.package.files
      $null     = $NuspecXml.package.RemoveChild($xmlfiles)

      # Create a new files element
      $xmlFiles = $NuspecXml.CreateElement('files', $xmlns)
    } else {
      $xmlFiles = $NuspecXml.package.files
    }

    foreach($file in $files) {
      $xmlFile = $NuspecXml.CreateElement('file', $xmlns)
      $xmlSrc = $NuspecXml.CreateAttribute('src')
      $xmlSrc.Value = $file.src
      $xmlTarget = $NuspecXml.CreateAttribute('target')
      $xmlTarget.Value = $file.target
      $null = $xmlFile.Attributes.Append($xmlSrc)
      $null = $xmlFile.Attributes.Append($xmlTarget)
      $null = $xmlfiles.AppendChild($xmlFile)
    }
    $null = $NuspecXml.package.AppendChild($xmlFiles)
  }


  if ($PSBoundParameters.count -gt 1) {
    # Set up formatting
    $xmlSettings = new-object System.Xml.XmlWriterSettings
    $xmlSettings.Indent = $true
    $xmlSettings.NewLineOnAttributes = $false

    # Create an XmlWriter and save the modified XML document
    $xmlWriter = [Xml.XmlWriter]::Create($AbsPath, $xmlSettings)
    $NuspecXml.Save($xmlWriter)
    $xmlWriter.Close()
  }

} # function


