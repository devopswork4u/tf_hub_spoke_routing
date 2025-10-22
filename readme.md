
#### Query for NGS
AzureDiagnostics
| where primaryIPv4Address_s contains "10.190.194.4" and direction_s contains "In" and type_s contains "block"