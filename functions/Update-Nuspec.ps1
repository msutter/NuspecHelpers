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

    #Confirm-NuspecDependenciesHashValidity $dependencies
    if ($ResetDependencies) {
      # clean dependencies
      $xmldependencies = $NuspecXml.package.metadata.dependencies
      $null     = $NuspecXml.package.metadata.RemoveChild($xmldependencies)

      # Create a new dependencies element
      $xmlDependencies = $NuspecXml.CreateElement('dependencies', $xmlns)
    } else {
      $xmlDependencies = $NuspecXml.package.metadata.dependencies
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

    if ($ResetFiles) {
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
      $null = $xmlFile.Attributes.Append($xmlSrc)

      $xmlTarget = $NuspecXml.CreateAttribute('target')
      $xmlTarget.Value = $file.target
      $null = $xmlFile.Attributes.Append($xmlTarget)

      if ($file.exclude) {
        $xmlExclude = $NuspecXml.CreateAttribute('exclude')
        $xmlExclude.Value = $file.exclude
        $null = $xmlFile.Attributes.Append($xmlExclude)
      }

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


