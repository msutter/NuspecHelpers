function Update-Nuspec {
<#
.SYNOPSIS

Updates a nuspec file.

.DESCRIPTION

Updates a nuspec file.
Values will be overwritten

frameworkAssemblies, developmentDependency and references not implemented for update

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
    'title',
    'authors',
    'owners',
    'description',
    'releaseNotes',
    'summary',
    'language',
    'projectUrl',
    'iconUrl',
    'licenseUrl',
    'copyright',
    'requireLicenseAcceptance',
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
      # Existing ?
      if ( -not [Object]::ReferenceEquals($NuspecXml.package.metadata.${ParamKey}, $null)) {
        $NuspecXml.package.metadata.${ParamKey} = $PSBoundParameters.${ParamKey}
      } else {
        $xmlElt  = $NuspecXml.CreateElement($ParamKey, $xmlns)
        $xmlText = $NuspecXml.CreateTextNode($PSBoundParameters.${ParamKey})
        $null = $xmlElt.AppendChild($xmlText)
        $null    = $NuspecXml.package.metadata.AppendChild($xmlElt)
      }
    }
  }

  # Update Dependencies
  if ($PSBoundParameters.ContainsKey('dependencies')) {

    $DepMandatoryKeys = @('id')
    $DepOptionalKeys = @('version')

    Confirm-NuspecHashArrayValidity -HashArray $dependencies -MandatoryKeys $DepMandatoryKeys -OptionalKeys $DepOptionalKeys

    if ($NuspecXml.package.metadata.dependencies) {
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

# # Document creation
# [xml]$xmlDoc = New-Object system.Xml.XmlDocument
# $xmlDoc.LoadXml("<?xml version=`"1.0`" encoding=`"utf-8`"?><Racine></Racine>")

# # Creation of a node and its text
# $xmlElt = $xmlDoc.CreateElement("Machine")
# $xmlText = $xmlDoc.CreateTextNode("Mach1")
# $xmlElt.AppendChild($xmlText)

# # Creation of a sub node
# $xmlSubElt = $xmlDoc.CreateElement("Adapters")
# $xmlSubText = $xmlDoc.CreateTextNode("Network")
# $xmlSubElt.AppendChild($xmlSubText)
# $xmlElt.AppendChild($xmlSubElt)

# # Creation of an attribute in the principal node
# $xmlAtt = $xmlDoc.CreateAttribute("IP")
# $xmlAtt.Value = "128.200.1.1"
# $xmlElt.Attributes.Append($xmlAtt)

# # Add the node to the document
# $xmlDoc.LastChild.AppendChild($xmlElt);

# # Store to a file 
# $xmlDoc.Save("c:\Temp\Temp\Fic.xml")

