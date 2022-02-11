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

########################
# Variable Collections #
########################

#Compliance policies
$compliancePolicies = Get-ChildItem -Path "Policies\Compliance*"

#Configuration policies
$ConfigurationPolicies = Get-ChildItem -Path "Policies\Configuration*"

#Endpoint Security policies
$endpointSecurityPolicies = Get-ChildItem -Path "Policies\Endpoint Security*"

#Managed App policies
$managedAppPolicies = Get-ChildItem -Path "Policies\Managed App*"

##################
# Export to JSON #
##################

$HeaderParams = @{
  'Content-Type'  = "application\json"
  'Authorization' = "Bearer $($ConnectGraph.access_token)"
}

#Compliance policies
try{
  foreach($policy in $compliancePolicies){
    $JSON = Get-Content $policy.fullName

    # If missing, adds a default required block scheduled action to the compliance policy request body, as this value is not returned when retrieving compliance policies.
    $scheduledActionsForRule = '"scheduledActionsForRule":[{"ruleName":"PasswordRequired","scheduledActionConfigurations":[{"actionType":"block","gracePeriodHours":0,"notificationTemplateId":"","notificationMessageCCList":[]}]}]'
    $JSON = $JSON.trimend("}")
    $JSON = $JSON.TrimEnd() + "," + "`r`n"
    $JSON = $JSON + $scheduledActionsForRule + "`r`n" + "}"

    $response = Invoke-RestMethod -Headers $HeaderParams -Uri "https://graph.microsoft.com/v1.0/deviceManagement/deviceCompliancePolicies" -UseBasicParsing -Method POST -ContentType "application/json" -Body $JSON
    write-host "Imported policy: $(($JSON | convertfrom-json).displayname)" -ForegroundColor green
  }
}
catch{
  write-host "Error: $($_.Exception.Message)" -ForegroundColor red
}

#Configuration policies
try{
  foreach($policy in $ConfigurationPolicies){
    $JSON = Get-Content $policy.fullName
    $response = Invoke-RestMethod -Headers $HeaderParams -Uri "https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations" -UseBasicParsing -Method POST -ContentType "application/json" -Body $JSON
    write-host "Imported policy: $(($JSON | convertfrom-json).displayname)" -ForegroundColor green
  }
}
catch{
  write-host "Error: $($_.Exception.Message)" -ForegroundColor red
}

#Endpoint Security policies
try{
  foreach($policy in $endpointSecurityPolicies){
    $JSON = Get-Content $policy.fullName
    $JSON_Convert = $JSON | ConvertFrom-Json
    $JSON_TemplateId = $JSON_Convert.templateId
    $response = Invoke-RestMethod -Headers $HeaderParams -Uri "https://graph.microsoft.com/beta/deviceManagement/templates/$JSON_TemplateId/createInstance" -UseBasicParsing -Method POST -ContentType "application/json" -Body $JSON
    write-host "Imported policy: $(($JSON | convertfrom-json).displayname)" -ForegroundColor green
  }
}
catch{
  write-host "Error: $($_.Exception.Message)" -ForegroundColor red
}