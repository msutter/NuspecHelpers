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

  # Specifies the ResetFiles
  [Parameter(Mandatory = $false)]
  [switch] $ResetFiles,

  # Specifies the ResetDependencies
  [Parameter(Mandatory = $false)]
  [switch] $ResetDependencies
)

  $MetadataStringParams = @(
    'id',
    'version',
    'authors',
    'owners',
    'projectUrl',
    'requireLicenseAcceptance',
    'description',
    'copyright',
    'tags'
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

  # Update Metadata String Params values
  foreach ($ParamKey in $MetadataStringParams ) {
    if ($PSBoundParameters.ContainsKey($ParamKey)) {
      $NuspecXml.package.metadata.${ParamKey} = $PSBoundParameters.${ParamKey}
    }
  }

  # Update Dependencies
  if ($PSBoundParameters.ContainsKey('dependencies')) {

    $DepMandatoryKeys = @('id')
    $DepOptionalKeys = @('version')

    Confirm-NuspecHashArrayValidity -HashArray $dependencies -MandatoryKeys $DepMandatoryKeys -OptionalKeys $DepOptionalKeys

    if ( $NuspecXml.package.metadata.dependencies) {
      # There are existing deps
      $xmldependencies = $NuspecXml.package.metadata.dependencies

      # Check if they should be reseted
      if ($ResetDependencies) {
        $null = $NuspecXml.package.metadata.RemoveChild($xmldependencies)
        $xmlDependencies = $NuspecXml.CreateElement('dependencies', $xmlns)
      }

    } else {
      # No existing deps, creating the element
      $xmlDependencies = $NuspecXml.CreateElement('dependencies', $xmlns)
    }

    foreach($dependency in $dependencies) {
      $xmlFile = $NuspecXml.CreateElement('dependency', $xmlns)

      $xmlId = $NuspecXml.CreateAttribute('id')
      $xmlId.Value = $dependency.id
      $null = $xmlFile.Attributes.Append($xmlId)

      if ($dependency.version) {
        $xmlVersion = $NuspecXml.CreateAttribute('version')
        $xmlVersion.Value = $dependency.version
        $null = $xmlFile.Attributes.Append($xmlVersion)
      }

      $null = $xmldependencies.AppendChild($xmlFile)
    }
    $null = $NuspecXml.package.metadata.AppendChild($xmlDependencies)
  }


  # Update Files
  if ($PSBoundParameters.ContainsKey('files')) {

    $FileMandatoryKeys = @('src','target')
    $FileOptionalKeys = @('exclude')

    Confirm-NuspecHashArrayValidity -HashArray $files -MandatoryKeys $FileMandatoryKeys -OptionalKeys $FileOptionalKeys

    if ( $NuspecXml.package.files) {
      # There are existing files
      $xmlFiles = $NuspecXml.package.files

      # Check if they should be reseted
      if ($ResetFiles) {
        $null = $NuspecXml.package.RemoveChild($xmlFiles)
        $xmlFiles = $NuspecXml.CreateElement('files', $xmlns)
      }

    } else {
      # No existing deps, creating the element
      $xmlFiles = $NuspecXml.CreateElement('files', $xmlns)
    }

    foreach($file in $files) {
      $xmlFile = $NuspecXml.CreateElement('file', $xmlns)

      $xmlSrc = $NuspecXml.CreateAttribute('src')
      $xmlSrc.Value = $file.src
      $null = $xmlFile.Attributes.Append($xmlSrc)

      $xmlTarget = $NuspecXml.CreateAttribute('target')
      $xmlTarget.Value = $file.target
      $null = $xmlFile.Attributes.Append($xmlTarget)

      if ($file.exclude) {
        $xmlExclude = $NuspecXml.CreateAttribute('exclude')
        $xmlExclude.Value = $file.exclude
        $null = $xmlFile.Attributes.Append($xmlExclude)
      }

      $null = $xmlFiles.AppendChild($xmlFile)
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


