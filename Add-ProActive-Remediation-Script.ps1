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


################################
# Create ProActiveRemediation #
################################

$body = @{
  "displayName" = "RemoveQuickAssist";
  "description" = "This script will remove the default Windows Quick Assist application";
  "publisher" = "@LoginConsultants";
  "runAs32Bit" = $true;
  "runAsAccount" = "system";
  "enforceSignatureCheck" = $false;
  "detectionScriptContent" = "PCMKICAgIEZpbGVOYW1lOiAgICBEZXRlY3RlY3RfcXVpY2thc3Npc3QucHMxCiAgICBBdXRob3I6ICAgICAgT2xhIFN0csO2bQogICAgQ29udGFjdDogICAgIEBvbGFzdHJvbWNvbQogICAgQ3JlYXRlZDogICAgIDIwMjEtMTItMTMKICAgIFVwZGF0ZWQ6ICAgICAyMDIxLTEyLTEzCiAgICBWZXJzaW9uIGhpc3Rvcnk6CiAgICAxLjAuMCAtICgyMDIxLTEyLTEzKSBTY3JpcHQgY3JlYXRlZAojPgoKJFdpbkNhcCA9IEdldC1XaW5kb3dzQ2FwYWJpbGl0eSAtb25saW5lIC1uYW1lIEFwcC5TdXBwb3J0LlF1aWNrQXNzaXN0KgoKSWYgKCRXaW5DYXAuU3RhdGUgLW1hdGNoICJOb3RQcmVzZW50Iil7CiAgICBXcml0ZS1XYXJuaW5nICJXaW5kb3dzIENhcGFiaWxpdHkgLSBRdWljayBBc3Npc3QgbWlzc2luZyAtIGV4aXRpbmciCiAgICBFeGl0IDAKfQplbHNlIHsKICAgIFdyaXRlLUhvc3QgIldpbmRvd3MgQ2FwYWJpbGl0eSAtIFF1aWNrIEFzc2lzdCBpbnN0YWxsZWQsIFJ1bm5pbmcgUmVtZWRpYXRpb24gc2NyaXB0IgogICAgRXhpdCAxCn0=";
  "remediationScriptContent" = "PCMKICAgIEZpbGVOYW1lOiAgICByZW1vdmVfcXVpY2thc3NzaXQucHMxCiAgICBBdXRob3I6ICAgICAgT2xhIFN0csO2bQogICAgQ29udGFjdDogICAgIEBvbGFzdHJvbWNvbQogICAgQ3JlYXRlZDogICAgIDIwMjEtMTItMTMKICAgIFVwZGF0ZWQ6ICAgICAyMDIxLTEyLTEzCiAgICBWZXJzaW9uIGhpc3Rvcnk6CiAgICAxLjAuMCAtICgyMDIxLTEyLTEzKSBTY3JpcHQgY3JlYXRlZAojPgpSZW1vdmUtV2luZG93c0NhcGFiaWxpdHkgLW9ubGluZSAtbmFtZSBBcHAuU3VwcG9ydC5RdWlja0Fzc2lzdH5+fn4wLjAuMS4w"
  }

$requestBody = $body | ConvertTo-Json

$apiurl = "https://graph.microsoft.com/beta/deviceManagement/deviceHealthScripts"

$Data = Invoke-RestMethod -Headers $HeaderParams -Uri $apiUrl -Body $requestBody -Method Post -ContentType 'application/json'