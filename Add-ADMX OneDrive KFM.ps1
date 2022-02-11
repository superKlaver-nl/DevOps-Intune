[CmdletBinding()]


param (
    [Parameter(Mandatory = $true)]
    [string]$tenantId, 
    [Parameter(Mandatory =$true)]
    [string]$client_id, 
    [Parameter(Mandatory=$true)]
    [string]$client_secret
)

#$rootLocation =  $env:BUILD_ARTIFACTSTAGINGDIRECTORY
$rootLocation = $env:Build_SourcesDirectory
Write-Host "Working Directory is " + $rootLocation

Write-Host "PSScriptRoot is" $PSScriptRoot

#$Functions = @(gci -Path  $rootLocation\Functions\*.ps1 -ErrorAction SilentlyContinue)

# Source Functions

$Functions = @(Get-ChildItem -Path $rootLocation\Functions\*.ps1 -ErrorAction SilentlyContinue)
foreach ($f in $Functions){
    try {
        Write-Host "Importing function "  $($f.FullName)
        . $($f.FullName)

    }
    catch{
        Write-Error -Message "Failed to import function " + $($f.FullName)
    }
}

#################################
####### Create Token  ###########
################################# 



Write-Host "Getting Token"
$global:authToken = Get-AuthToken -client $($client_id) -secret $($client_secret) -tenant $($tenantId)
Write-Host "Token is " $global:authToken.Authorization

$baseUrl = "https://graph.microsoft.com/beta/deviceAppManagement/"

$logRequestUris = $true;
$logHeaders = $false;
$logContent = $true;

$azureStorageUploadChunkSizeInMb = 6l;

$sleep = 30


###################################################################################################
## Functions used in the script
###################################################################################################


Function Create-GroupPolicyConfigurations(){
		
<#
.SYNOPSIS
This function is used to add an device configuration policy using the Graph API REST interface
.DESCRIPTION
The function connects to the Graph API Interface and adds a device configuration policy
.EXAMPLE
Add-DeviceConfigurationPolicy -JSON $JSON
Adds a device configuration policy in Intune
.NOTES
NAME: Add-DeviceConfigurationPolicy
#>
		
		[cmdletbinding()]
		param
		(
			$DisplayName,
            $PolicyDescription
		)
		
		$jsonCode = @"
{
    "description":"$($PolicyDescription)",
    "displayName":"$($DisplayName)"
}
"@
		
		$graphApiVersion = "Beta"
		$DCP_resource = "deviceManagement/groupPolicyConfigurations"
		Write-Verbose "Resource: $DCP_resource"
		
		try
		{
			
			$uri = "https://graph.microsoft.com/$graphApiVersion/$($DCP_resource)"
			$responseBody = Invoke-RestMethod -Uri $uri -Headers $authToken -Method Post -Body $jsonCode -ContentType "application/json"
			
			
		}
		
		catch
		{
			
			$ex = $_.Exception
			$errorResponse = $ex.Response.GetResponseStream()
			$reader = New-Object System.IO.StreamReader($errorResponse)
			$reader.BaseStream.Position = 0
			$reader.DiscardBufferedData()
			$responseBody = $reader.ReadToEnd();
			Write-Host "Response content:`n$responseBody" -f Red
			Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
			write-host
			break
			
		}
		$responseBody.id
}
	
####################################################
	
Function Create-GroupPolicyConfigurationsDefinitionValues(){
		
    <#
    .SYNOPSIS
    This function is used to get device configuration policies from the Graph API REST interface
    .DESCRIPTION
    The function connects to the Graph API Interface and gets any device configuration policies
    .EXAMPLE
    Get-DeviceConfigurationPolicy
    Returns any device configuration policies configured in Intune
    .NOTES
    NAME: Get-GroupPolicyConfigurations
    #>
		
		[cmdletbinding()]
		Param (
			
			[string]$GroupPolicyConfigurationID,
			$JSON
			
		)
		
		$graphApiVersion = "Beta"
		
		$DCP_resource = "deviceManagement/groupPolicyConfigurations/$($GroupPolicyConfigurationID)/definitionValues"
		write-host $DCP_resource
		try
		{
			if ($JSON -eq "" -or $JSON -eq $null)
			{
				
				write-host "No JSON specified, please specify valid JSON for the Device Configuration Policy..." -f Red
				
			}
			
			else
			{
				
				Test-JSON -JSON $JSON
				
				$uri = "https://graph.microsoft.com/$graphApiVersion/$($DCP_resource)"
				Invoke-RestMethod -Uri $uri -Headers $authToken -Method Post -Body $JSON -ContentType "application/json"
			}
			
		}
		
		catch
		{
			
			$ex = $_.Exception
			$errorResponse = $ex.Response.GetResponseStream()
			$reader = New-Object System.IO.StreamReader($errorResponse)
			$reader.BaseStream.Position = 0
			$reader.DiscardBufferedData()
			$responseBody = $reader.ReadToEnd();
			Write-Host "Response content:`n$responseBody" -f Red
			Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
			write-host
			break
			
		}
		
}
	
####################################################

Function Test-JSON(){
		
<#
.SYNOPSIS
This function is used to test if the JSON passed to a REST Post request is valid
.DESCRIPTION
The function tests if the JSON passed to the REST Post is valid
.EXAMPLE
Test-JSON -JSON $JSON
Test if the JSON is valid before calling the Graph REST interface
.NOTES
NAME: Test-AuthHeader
#>
		
		param (
			
			$JSON
			
		)
		
		try
		{
			
			$TestJSON = ConvertFrom-Json $JSON -ErrorAction Stop
			$validJson = $true
			
		}
		
		catch
		{
			
			$validJson = $false
			$_.Exception
			
		}
		
		if (!$validJson)
		{
			
			Write-Host "Provided JSON isn't in valid JSON format" -f Red
			break
			
		}
		
}

####################################################

###################################################################################################
## JSON describing the policies to be imported
###################################################################################################

$GPO_ODfBClient = @"
[
{
    "definition@odata.bind":  "https://graph.microsoft.com/beta/deviceManagement/groupPolicyDefinitions('81c07ba0-7512-402d-b1f6-00856975cfab')",
    "enabled":  "true"
},
{
    "definition@odata.bind":  "https://graph.microsoft.com/beta/deviceManagement/groupPolicyDefinitions('61b07a01-7e60-4127-b086-f6b32458a5c5')",
    "enabled":  "true"
},
{
    "definition@odata.bind":  "https://graph.microsoft.com/beta/deviceManagement/groupPolicyDefinitions('2ce2f507-aae8-49a1-98ce-dc3faafcd331')",
    "enabled":  "true"
},
{
    "definition@odata.bind":  "https://graph.microsoft.com/beta/deviceManagement/groupPolicyDefinitions('24bec81e-a596-4fc1-867b-0256114a19a4')",
    "enabled":  "true",
    "presentationValues":  [
                               {
                                   "@odata.type":  "#microsoft.graph.groupPolicyPresentationValueText",
                                   "value":  "$TenantID",
                                   "presentation@odata.bind":  "https://graph.microsoft.com/beta/deviceManagement/groupPolicyDefinitions('24bec81e-a596-4fc1-867b-0256114a19a4')/presentations('4640c3f7-b89a-41be-948b-e86a2a97cae4')"
                               }
                           ]
},
{
    "definition@odata.bind":  "https://graph.microsoft.com/beta/deviceManagement/groupPolicyDefinitions('39147fa2-6c5e-437b-8264-19b50b891709')",
    "enabled":  "true",
    "presentationValues":  [
                               {
                                   "@odata.type":  "#microsoft.graph.groupPolicyPresentationValueText",
                                   "value":  "$TenantID",
                                   "presentation@odata.bind":  "https://graph.microsoft.com/beta/deviceManagement/groupPolicyDefinitions('39147fa2-6c5e-437b-8264-19b50b891709')/presentations('fbefbbdf-5382-477c-8b6c-71f4a06e2805')"
                               }
                           ]
}
]
"@


###################################################################################################
## Import the ADMX Configuration profiles from JSON
###################################################################################################

## Create the ADMX Configuration profile
$Policy_Name = "Configuration - Windows 10 OneDrive KFM"
$Policy_Description = "Configures OneDrive Known Folder Move"
$GroupPolicyConfigurationID = Create-GroupPolicyConfigurations -DisplayName $Policy_Name -PolicyDescription $Policy_Description
## Populate the policy with settings
$JSON_Convert = $GPO_ODfBClient | ConvertFrom-Json
$JSON_Convert | ForEach-Object { $_
    
            	$JSON_Output = ConvertTo-Json -Depth 5 $_
                
                Write-Host $JSON_Output

            	Create-GroupPolicyConfigurationsDefinitionValues -JSON $JSON_Output -GroupPolicyConfigurationID $GroupPolicyConfigurationID 
        	 }



Write-Host "####################################################################################################" -ForegroundColor Yellow
Write-Host "Policy: " $Policy_Name "created" -ForegroundColor Yellow
Write-Host "####################################################################################################" -ForegroundColor Yellow