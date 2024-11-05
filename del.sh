#!/bin/bash

# Set your Azure Resource Group and DNS Zone name
RESOURCE_GROUP="prod_cogdns_west_us_rg"    # Replace with your Azure Resource Group for the DNS zone
DNS_ZONE_NAME="cognitoz.my"                # Replace with your DNS zone name

# Path to the CSV file with format: pip,username
CSV_FILE="students.csv"  # Replace with your CSV filename if different

# Check if CSV file exists
if [[ ! -f "$CSV_FILE" ]]; then
  echo "CSV file $CSV_FILE not found!"
  exit 1
fi

# Loop through each line in the CSV file
while IFS=',' read -r pip username
do
  # Skip the header line if it exists
  if [[ "$pip" == "pip" && "$username" == "username" ]]; then
    continue
  fi

  # Define the DNS record names based on username
  hostdns1="app1${username}.cognitoz.my"
  hostdns2="app2${username}.cognitoz.my"
  hostdns3="rbstu${username: -1}.cognitoz.my"

  # Delete A record for HostDNS1
  echo "Deleting DNS record for $hostdns1"
  az network dns record-set a delete \
    --resource-group "$RESOURCE_GROUP" \
    --zone-name "$DNS_ZONE_NAME" \
    --name "${hostdns1%%.*}" \
    --yes

  # Delete A record for HostDNS2
  echo "Deleting DNS record for $hostdns2"
  az network dns record-set a delete \
    --resource-group "$RESOURCE_GROUP" \
    --zone-name "$DNS_ZONE_NAME" \
    --name "${hostdns2%%.*}" \
    --yes

  # Delete A record for HostDNS3
  echo "Deleting DNS record for $hostdns3"
  az network dns record-set a delete \
    --resource-group "$RESOURCE_GROUP" \
    --zone-name "$DNS_ZONE_NAME" \
    --name "${hostdns3%%.*}" \
    --yes

done < "$CSV_FILE"

echo "All DNS entries deleted successfully."
