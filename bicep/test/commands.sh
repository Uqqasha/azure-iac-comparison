cmd_provision="az deployment group create -g RG-${region}-${iac_tool}-${execution} -p root.bicepparam --verbose"
cmd_unprovision="az deployment group create -g RG-${region}-${iac_tool}-${execution} -f cleanup.bicep --mode complete --verbose"