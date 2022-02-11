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


$baseUri = 'https://graph.microsoft.com/beta/deviceManagement/configurationPolicies'

#region build the policy
$newPolicy = [pscustomobject]@{
    name         = "Configuration - Windows Delivery Optimization"
    description  = "Windows Delivery Optimization"
    platforms    = "windows10"
    technologies = "mdm"
    settings     = @(
        @{
            '@odata.type'   = "#microsoft.graph.deviceManagementConfigurationSetting"
            settingInstance = @{
                '@odata.type'       = "#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance"
                settingDefinitionId = "device_vendor_msft_policy_config_deliveryoptimization_doabsolutemaxcachesize"
                simpleSettingValue  = @{
                    '@odata.type' = "#microsoft.graph.deviceManagementConfigurationIntegerSettingValue"
                    value         = "30"
                }
            }
        }
        @{
            '@odata.type'   = "#microsoft.graph.deviceManagementConfigurationSetting"
            settingInstance = @{
                '@odata.type'       = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
                settingDefinitionId = "device_vendor_msft_policy_config_deliveryoptimization_doallowvpnpeercaching"
                choiceSettingValue  = @{
                    value         = "device_vendor_msft_policy_config_deliveryoptimization_doallowvpnpeercaching_0"
                }
            }
        }
        @{
            '@odata.type'   = "#microsoft.graph.deviceManagementConfigurationSetting"
            settingInstance = @{
                '@odata.type'       = "#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance"
                settingDefinitionId = "device_vendor_msft_policy_config_deliveryoptimization_dodelaybackgrounddownloadfromhttp"
                simpleSettingValue  = @{
                    '@odata.type' = "#microsoft.graph.deviceManagementConfigurationIntegerSettingValue"
                    value         = "600"
                }
            }
        }
        @{
            '@odata.type'   = "#microsoft.graph.deviceManagementConfigurationSetting"
            settingInstance = @{
                '@odata.type'       = "#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance"
                settingDefinitionId = "device_vendor_msft_policy_config_deliveryoptimization_dodelaycacheserverfallbackbackground"
                simpleSettingValue  = @{
                    '@odata.type' = "#microsoft.graph.deviceManagementConfigurationIntegerSettingValue"
                    value         = "60"
                }
            }
        }
        @{
            '@odata.type'   = "#microsoft.graph.deviceManagementConfigurationSetting"
            settingInstance = @{
                '@odata.type'       = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
                settingDefinitionId = "device_vendor_msft_policy_config_deliveryoptimization_dodownloadmode"
                choiceSettingValue  = @{
                    value         = "device_vendor_msft_policy_config_deliveryoptimization_dodownloadmode_1"
                }
            }
        }
        @{
            '@odata.type'   = "#microsoft.graph.deviceManagementConfigurationSetting"
            settingInstance = @{
                '@odata.type'       = "#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance"
                settingDefinitionId = "device_vendor_msft_policy_config_deliveryoptimization_domaxcacheage"
                simpleSettingValue  = @{
                    '@odata.type' = "#microsoft.graph.deviceManagementConfigurationIntegerSettingValue"
                    value         = "0"
                }
            }
        }
        @{
            '@odata.type'   = "#microsoft.graph.deviceManagementConfigurationSetting"
            settingInstance = @{
                '@odata.type'       = "#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance"
                settingDefinitionId = "device_vendor_msft_policy_config_deliveryoptimization_dominbackgroundqos"
                simpleSettingValue  = @{
                    '@odata.type' = "#microsoft.graph.deviceManagementConfigurationIntegerSettingValue"
                    value         = "64"
                }
            }
        }
        @{
            '@odata.type'   = "#microsoft.graph.deviceManagementConfigurationSetting"
            settingInstance = @{
                '@odata.type'       = "#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance"
                settingDefinitionId = "device_vendor_msft_policy_config_deliveryoptimization_dominbatterypercentageallowedtoupload"
                simpleSettingValue  = @{
                    '@odata.type' = "#microsoft.graph.deviceManagementConfigurationIntegerSettingValue"
                    value         = "40"
                }
            }
        }
        @{
            '@odata.type'   = "#microsoft.graph.deviceManagementConfigurationSetting"
            settingInstance = @{
                '@odata.type'       = "#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance"
                settingDefinitionId = "device_vendor_msft_policy_config_deliveryoptimization_dominfilesizetocache"
                simpleSettingValue  = @{
                    '@odata.type' = "#microsoft.graph.deviceManagementConfigurationIntegerSettingValue"
                    value         = "1"
                }
            }
        }
        @{
            '@odata.type'   = "#microsoft.graph.deviceManagementConfigurationSetting"
            settingInstance = @{
                '@odata.type'       = "#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance"
                settingDefinitionId = "device_vendor_msft_policy_config_deliveryoptimization_dominramallowedtopeer"
                simpleSettingValue  = @{
                    '@odata.type' = "#microsoft.graph.deviceManagementConfigurationIntegerSettingValue"
                    value         = "2"
                }
            }
        }
        @{
            '@odata.type'   = "#microsoft.graph.deviceManagementConfigurationSetting"
            settingInstance = @{
                '@odata.type'       = "#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance"
                settingDefinitionId = "device_vendor_msft_policy_config_deliveryoptimization_domonthlyuploaddatacap"
                simpleSettingValue  = @{
                    '@odata.type' = "#microsoft.graph.deviceManagementConfigurationIntegerSettingValue"
                    value         = "0"
                }
            }
        }
        @{
            '@odata.type'   = "#microsoft.graph.deviceManagementConfigurationSetting"
            settingInstance = @{
                '@odata.type'       = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
                settingDefinitionId = "device_vendor_msft_policy_config_deliveryoptimization_dorestrictpeerselectionby"
                choiceSettingValue  = @{
                    value         = "device_vendor_msft_policy_config_deliveryoptimization_dorestrictpeerselectionby_1"
                }
            }
        }
    )
}
#endregion
#region post the request
$restParams = @{
    Method      = 'Post'
    Uri         = $baseUri
    body        = ($newPolicy | ConvertTo-Json -Depth 20)
    Headers     = $HeaderParams
    ContentType = 'Application/Json'
}
Invoke-RestMethod @restParams
#endregion
