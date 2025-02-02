<#
.DESCRIPTION
    Transform an xml file using Microsofts transformation utillity (same as our old builds)

.SYNOPSIS
    Run an xml transform

.PARAMETER xml
    The xml file to transform

.PARAMETER xdt
    The file of transformations to apply

.PARAMETER output
    The resulting output file

.LINK
    https://gist.github.com/Warrenn/a47426f248185c40a2c3

.EXAMPLE
    .\XmlTransform.ps1 -xml "ClearBank.Swift.Messaging.ServiceFabric.Api.Command\App.config" -xdt "build\Build\Hosted\Global\Global.config" -output "ClearBank.Swift.Messaging.ServiceFabric.Api.Command\app.prod.config"
#>

param(
    [string]$xml,
    [string]$xdt,
    [string]$output
)

if (!$xml -or !(Test-Path -path $xml -PathType Leaf)) {
    throw "File not found. $xml";
}
if (!$xdt -or !(Test-Path -path $xdt -PathType Leaf)) {
    throw "File not found. $xdt";
}
if (!$output -or !(Test-Path -path $output -PathType Container)) {
    throw "Folder not found. $output";
}

$transformDll = ""
if (Test-Path (Join-Path $PSScriptRoot -ChildPath "Microsoft.Web.XmlTransform.dll")){
    $transformDll = Join-Path $PSScriptRoot -ChildPath "Microsoft.Web.XmlTransform.dll"
}
if(Test-Path "C:\Program Files (x86)\MSBuild\Microsoft\VisualStudio\v12.0\Web\Microsoft.Web.XmlTransform.dll"){
    $transformDll = "C:\Program Files (x86)\MSBuild\Microsoft\VisualStudio\v12.0\Web\Microsoft.Web.XmlTransform.dll"
}
if(($transformDll -eq "")-and(Test-Path "C:\Program Files (x86)\MSBuild\Microsoft\VisualStudio\v11.0\Web\Microsoft.Web.XmlTransform.dll")){
    $transformDll = "C:\Program Files (x86)\MSBuild\Microsoft\VisualStudio\v11.0\Web\Microsoft.Web.XmlTransform.dll"
}
if(($transformDll -eq "")-and(Test-Path "C:\Program Files (x86)\MSBuild\Microsoft\VisualStudio\v10.0\Web\Microsoft.Web.XmlTransform.dll")){
    $transformDll = "C:\Program Files (x86)\MSBuild\Microsoft\VisualStudio\v10.0\Web\Microsoft.Web.XmlTransform.dll"
}
if($transformDll -eq ""){
    $scriptPath = (Get-Variable MyInvocation -Scope 1).Value.InvocationName | split-path -parent
    $transformDll = "$($scriptPath)\Microsoft.Web.XmlTransform.dll"
}
if(($transformDll -eq "")-and(Test-Path "$($PSScriptRoot)\Microsoft.Web.XmlTransform.dll")){
    $transformDll = "$($PSScriptRoot)\Microsoft.Web.XmlTransform.dll"
}

Write-Host "Adding:" $transformDll
Add-Type -Path $transformDll

$xmldoc = New-Object Microsoft.Web.XmlTransform.XmlTransformableDocument;
$xmldoc.PreserveWhitespace = $true
$xmldoc.Load($xml);

$transf = New-Object Microsoft.Web.XmlTransform.XmlTransformation($xdt);
if ($transf.Apply($xmldoc) -eq $false)
{
    throw "Transformation failed."
}
$xmldoc.Save($output);

Write-Host "Written file:" $output
