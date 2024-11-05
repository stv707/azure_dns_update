#### Bash script that you can run in Azure Cloud Shell or any environment with Azure CLI installed. 
#### This script reads a CSV file with columns `pip` and `username` and creates DNS A records in Azure DNS for each entry.

### Script: `run.sh`

```bash
#!/bin/bash

# Set your Azure Resource Group and DNS Zone name
RESOURCE_GROUP="prod_cogdns_west_us_rg"    # Replace with your Azure Resource Group for the DNS zone
DNS_ZONE_NAME="cognitoz.my"              # Replace with your DNS zone name

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

  # Create A record for HostDNS1
  echo "Creating DNS record for $hostdns1 pointing to $pip"
  az network dns record-set a add-record \
    --resource-group "$RESOURCE_GROUP" \
    --zone-name "$DNS_ZONE_NAME" \
    --record-set-name "${hostdns1%%.*}" \
    --ipv4-address "$pip"

  # Create A record for HostDNS2
  echo "Creating DNS record for $hostdns2 pointing to $pip"
  az network dns record-set a add-record \
    --resource-group "$RESOURCE_GROUP" \
    --zone-name "$DNS_ZONE_NAME" \
    --record-set-name "${hostdns2%%.*}" \
    --ipv4-address "$pip"

  # Create A record for HostDNS3
  echo "Creating DNS record for $hostdns3 pointing to $pip"
  az network dns record-set a add-record \
    --resource-group "$RESOURCE_GROUP" \
    --zone-name "$DNS_ZONE_NAME" \
    --record-set-name "${hostdns3%%.*}" \
    --ipv4-address "$pip"

done < "$CSV_FILE"

echo "All DNS entries created successfully."
```

### Instructions

1. Save your CSV file as `students.csv` with this format:
   ```
   pip,username
   XX.XX.XX.XX,stu1
   XX.XX.XX.XX,stu2
   ...
   ```

2. Replace `your_resource_group` and `cognitoz.my` in the script with the actual values for your Azure DNS setup.

3. Run the script in Azure Cloud Shell or any Linux-based environment with Azure CLI installed using:
   ```bash
   bash create_dns_entries.sh
   ```

This script will iterate over each line in `students.csv` and create three DNS A records for each student with their respective Public IP (`pip`). Each entry will generate records for `HostDNS1`, `HostDNS2`, and `HostDNS3`. 


----

#### Delete the DNS entries in Azure DNS based on the same `students.csv` file used for creation. 
#### This script will remove the A records for `HostDNS1`, `HostDNS2`, and `HostDNS3` associated with each student.

### Script: `del.sh`

```bash
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
```

### Instructions

1. Ensure your `students.csv` file is in the same format:
   ```
   pip,username
   XX.XX.XX.XX,stu1
   XX.XX.XX.XX,stu2
   ...
   ```

2. Set `RESOURCE_GROUP` to `prod_cogdns_west_us_rg` and `DNS_ZONE_NAME` to `cognitoz.my`.

3. Run the script in Azure Cloud Shell or any Linux-based environment with Azure CLI installed using:
   ```bash
   bash delete_dns_entries.sh
   ```

This script will delete the DNS A records (`HostDNS1`, `HostDNS2`, and `HostDNS3`) for each entry in the `students.csv` file by referencing the student usernames and their corresponding DNS names.