

# Change NSG firewall rule to restrict Postgres and MySQL database from client machine only

# Find out your local client ip address. 

echo -e "\n This script shows the NSG allowed source for your MySQL and Postgres database container NIC \n"


# In this resource group, there is only one  NSG

export rg_nsg="MC_OSSDBMigration_ossdbmigration_westus"
export nsg_name=` az network nsg list  -g $rg_nsg --query "[].name" -o tsv`

# For this NSG, there are two rules for connecting to Postgres and MySQL.

export pg_nsg_rule_name=`az network nsg rule list -g $rg_nsg --nsg-name $nsg_name --query "[].[name]" -o tsv | grep "TCP-5432" `
export my_nsg_rule_name=`az network nsg rule list -g $rg_nsg --nsg-name $nsg_name --query "[].[name]" -o tsv | grep "TCP-3306" `

# Capture the existing allowed_source_ip_address. 

existing_my_source_ip_allowed=`az network nsg rule show  -g $rg_nsg --nsg-name $nsg_name --name $my_nsg_rule_name --query "sourceAddressPrefix" -o tsv`
existing_pg_source_ip_allowed=`az network nsg rule show  -g $rg_nsg --nsg-name $nsg_name --name $pg_nsg_rule_name --query "sourceAddressPrefix" -o tsv`

# If it says "Internet" we treat it as 0.0.0.0

if [ "$existing_my_source_ip_allowed" = "Internet" ]
then
  existing_my_source_ip_allowed="0.0.0.0"
fi


if [ "$existing_pg_source_ip_allowed" = "Internet" ]
then
   existing_pg_source_ip_allowed="0.0.0.0"
fi

# if the existing source ip allowed is open to the world - then we need to remove it first. Otherwise it is a ( list of ) IP addresses then 
# we append to it another IP address. Open the world is 0.0.0.0 or 0.0.0.0/0. 


existing_my_source_ip_allowed_prefix=`echo $existing_my_source_ip_allowed | cut  -d "/" -f1`
existing_pg_source_ip_allowed_prefix=`echo $existing_pg_source_ip_allowed | cut  -d "/" -f1`

# If it was open to public, we take off the existing 0.0.0.0 or else we append to it.

echo -e " The allowed IP source address for Postgres is $existing_pg_source_ip_allowed_prefix \n"

echo -e " The allowed IP source address for MySQL is $existing_my_source_ip_allowed_prefix \n"



