param(
  [Parameter(mandatory = $true)]
  [String]$client_Id,
  [Parameter(mandatory = $true)]
  [String]$client_Secret,
  [Parameter(mandatory = $true)]
  [String]$tenantId,
  [Parameter(mandatory = $true)]
  [String]$GroupTag
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

##################################
# Add security groups for Intune #
##################################

$JSON = @{
  displayName     = "Intune-Users"
  mailEnabled     = $false
  securityEnabled = $true
  mailNickname    = "Intune-Users"
 }

 $bodyAsJson = $JSON | ConvertTo-Json

 $GrapGroupUrl = "https://graph.microsoft.com/v1.0/groups"
 $Group = Invoke-RestMethod -Uri $GrapGroupUrl -Headers $HeaderParams -Body $bodyAsJson -Method POST -ContentType 'application/json'

##DynamicGroupRule Properties:
$DynamicGroupRule = "(device.devicePhysicalIds -any _ -contains  ""[ZTDId]"")"

write-host "DynamicGroupRule:" $DynamicGroupRule
        
# Creating group
$Group_URL = "https://graph.microsoft.com/v1.0/groups"    
$group = @{
    "displayName" = "Intune-AutoPilot Devices";
    "description" = "Windows Autopilot Security Group";
    "groupTypes" = @("DynamicMembership");
    "mailEnabled" = $False;
    "mailNickname" = "WindowsAutoPilot";
    "membershipRule" = $DynamicGroupRule;
    "membershipRuleProcessingState" = "On";
    "securityEnabled" = $True
}    


$requestBody = $group | ConvertTo-Json #-Depth 5
write-host "group" $requestBody

$Create_group = Invoke-RestMethod -Headers $HeaderParams -Uri $Group_URL -Method POST -Body $requestBody -ContentType 'application/json'
# $Group_ID = $Create_group.id

##DynamicGroupRule Properties:
$DynamicGroupRule = "(device.devicePhysicalIds -any _ -eq ""[OrderID]:$GroupTag"")"

write-host "DynamicGroupRule:" $DynamicGroupRule
        
# Creating group
$Group_URL = "https://graph.microsoft.com/v1.0/groups"    
$group = @{
    "displayName" = "Intune-AutoPilot Devices Group Tag";
    "description" = "Windows Autopilot Security Group OrderID $GroupTag";
    "groupTypes" = @("DynamicMembership");
    "mailEnabled" = $False;
    "mailNickname" = "WindowsAutoPilotGroup-$GroupTag";
    "membershipRule" = $DynamicGroupRule;
    "membershipRuleProcessingState" = "On";
    "securityEnabled" = $True
}    

$requestBody = $group | ConvertTo-Json #-Depth 5
write-host "group" $requestBody

$Create_group = Invoke-RestMethod -Headers $HeaderParams -Uri $Group_URL -Method POST -Body $requestBody -ContentType 'application/json'
# $Group_ID = $Create_group.id