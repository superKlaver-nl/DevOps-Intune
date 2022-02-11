param(
  [Parameter(mandatory = $true)]
  [String]$client_Id,
  [Parameter(mandatory = $true)]
  [String]$client_Secret,
  [Parameter(mandatory = $true)]
  [String]$tenantId
)

####################
# Connect to Graph #
####################
$Body = @{    
  Grant_Type    = "client_credentials"
  resource      = "https://graph.microsoft.com"
  client_id     = $client_Id
  client_secret = $client_Secret
  } 
  
  $ConnectGraph = Invoke-RestMethod -Uri "https://login.microsoft.com/$tenantId/oauth2/token?api-version=1.0" -Method POST -Body $Body 

  $HeaderParams = @{
  'Content-Type'  = "application\json"
  'Authorization' = "Bearer $($ConnectGraph.access_token)"
}


# ***************************************************************************************
#                                     Create Autopilot Standard User  
# ***************************************************************************************
$AutopilotProfileName = "Windows Autopilot Standard User"
$AutopilotProfileDescription = "Windows Azure AD Join AutoPilot Profile for Standard User"
$Profile_Body = @{
    "@odata.type"                          = "#microsoft.graph.azureADWindowsAutopilotDeploymentProfile"
    displayName                            = "$($AutopilotProfileName)"
    description                            = "$($AutopilotProfileDescription)"
    language                               = 'os-default'
    extractHardwareHash                    = $true
    deviceNameTemplate                     = "DEMO-%RAND:4%"
    enableWhiteGlove                       = $true
    outOfBoxExperienceSettings             = @{
        "@odata.type"             = "microsoft.graph.outOfBoxExperienceSettings"
        hidePrivacySettings       = $true
        hideEULA                  = $true
        userType                  = 'Standard'
        deviceUsageType           = 'singleuser'
        skipKeyboardSelectionPage = $false
        hideEscapeLink            = $true
    }
    enrollmentStatusScreenSettings         = @{
        '@odata.type'                                    = "microsoft.graph.windowsEnrollmentStatusScreenSettings"
        hideInstallationProgress                         = $true
        allowDeviceUseBeforeProfileAndAppInstallComplete = $true
        blockDeviceSetupRetryByUser                      = $false
        allowLogCollectionOnInstallFailure               = $true
        customErrorMessage                               = "An error has occured. Please contact your IT Administrator"
        installProgressTimeoutInMinutes                  = "45"
        allowDeviceUseOnInstallFailure                   = $true
    }
} | ConvertTo-Json        
        
$Profile_URL = "https://graph.microsoft.com/beta/deviceManagement/windowsAutopilotDeploymentProfiles"
$Create_Profile = Invoke-RestMethod -Headers $HeaderParams  -Uri $Profile_URL -Method POST -Body $Profile_Body -ContentType 'application/json'

# ***************************************************************************************
#                                     Create Autopilot Admin User  
# ***************************************************************************************
$AutopilotProfileName = "Windows Autopilot Admin User"
$AutopilotProfileDescription = "Windows Azure AD Join AutoPilot Profile for Admin User"
$Profile_Body = @{
    "@odata.type"                          = "#microsoft.graph.azureADWindowsAutopilotDeploymentProfile"
    displayName                            = "$($AutopilotProfileName)"
    description                            = "$($AutopilotProfileDescription)"
    language                               = 'os-default'
    extractHardwareHash                    = $true
    deviceNameTemplate                     = "DEMO-%RAND:4%"
    enableWhiteGlove                       = $true
    outOfBoxExperienceSettings             = @{
        "@odata.type"             = "microsoft.graph.outOfBoxExperienceSettings"
        hidePrivacySettings       = $true
        hideEULA                  = $true
        userType                  = 'Administrator'
        deviceUsageType           = 'singleuser'
        skipKeyboardSelectionPage = $false
        hideEscapeLink            = $true
    }
    enrollmentStatusScreenSettings         = @{
        '@odata.type'                                    = "microsoft.graph.windowsEnrollmentStatusScreenSettings"
        hideInstallationProgress                         = $true
        allowDeviceUseBeforeProfileAndAppInstallComplete = $true
        blockDeviceSetupRetryByUser                      = $false
        allowLogCollectionOnInstallFailure               = $true
        customErrorMessage                               = "An error has occured. Please contact your IT Administrator"
        installProgressTimeoutInMinutes                  = "45"
        allowDeviceUseOnInstallFailure                   = $true
    }
} | ConvertTo-Json        
        
$Profile_URL = "https://graph.microsoft.com/beta/deviceManagement/windowsAutopilotDeploymentProfiles"
$Create_Profile = Invoke-RestMethod -Headers $HeaderParams  -Uri $Profile_URL -Method POST -Body $Profile_Body -ContentType 'application/json'
