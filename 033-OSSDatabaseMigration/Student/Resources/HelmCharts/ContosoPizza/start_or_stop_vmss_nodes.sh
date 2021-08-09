
# Stop the VMSS that AKS runs on - to stop incurring compute charges. There are only two VMSS in the resource group -one each for systempool and userpool.
# If your resource group is named differently change the -g parameter below. 

action=${1,,}

if [ $# = 0 ] 
then
 echo -e "\n Please re run this script with a flag - stop or start \n"
 exit 0
fi

export vmss_user=$(az vmss list -g MC_OSSDBMigration_ossdbmigration_westus --query '[].name' | grep userpool | tr -d "," | tr -d '"')
export vmss_system=$(az vmss list -g MC_OSSDBMigration_ossdbmigration_westus --query '[].name' | grep systempool | tr -d "," | tr -d '"')

# Now stop or start the VM scale sets


if [ $action = "stop" ] 
then
  echo -e "\n Stopping the nodes of the vm scale sets \n"
  az vmss stop -g MC_OSSDBMigration_ossdbmigration_westus -n $vmss_user
  az vmss stop -g MC_OSSDBMigration_ossdbmigration_westus -n $vmss_system
elif [ $action = "start" ] 
then
  echo -e "\n Starting the nodes of the vm scale sets \n"
  az vmss start  -g MC_OSSDBMigration_ossdbmigration_westus -n $vmss_system
  az vmss start -g MC_OSSDBMigration_ossdbmigration_westus -n $vmss_user
else
 echo -e "\n I can only stop or start the nodes - please add a parameter start or stop to this script \n"
fi