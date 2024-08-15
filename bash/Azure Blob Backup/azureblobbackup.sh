# Before executing nsure NTP is installed & running
# sudo yum install ntp
# chkconfig ntpd on
# timedatectl set-timezone America/Los_Angeles
# ntpdate -u -s 0.centos.pool.ntp.org
# systemctl restart ntpd
# hwclock -w

# Install Azure CLI
# sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
#
# sudo sh -c 'echo -e "[azure-cli]
# name=Azure CLI
# baseurl=https://packages.microsoft.com/yumrepos/azure-cli
# enabled=1
# gpgcheck=1
# gpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo'
# sudo yum install azure-cli

# Connect Azure CLI
# az login -u UNAME@cohesityse.onmicrosoft.com -p PWORD

# Begin Script
#
AZURE_ACCOUNT_NAME=349092cloudazure66
AZURE_ACCOUNT_KEY=YjKz6w/l8bCn3Jrzcnp9+xy0yrjCiYoLOmYFtNOua2sQ/41mUZ8nJ2rRikidymuUphowpd3VcXiF+AStarAUgQ==
MOUNT=/mnt/nfs/AzureBlobBackup

AZURE_CONTAINERS=($(
    az storage container list --account-name $AZURE_ACCOUNT_NAME --account-key $AZURE_ACCOUNT_KEY --query [*].name --output tsv
))

for CONTAINER in "${AZURE_CONTAINERS[@]}"

do
    if [ -d "$MOUNT/$AZURE_ACCOUNT_NAME/$CONTAINER" ]; then
        echo "";
        echo "Directory $MOUNT/$AZURE_ACCOUNT_NAME/$CONTAINER already exists ...";
        echo "Update existing container ...";
    else
        echo "";
        echo "New container detected ...";
        echo "Creating directory $MOUNT/$AZURE_ACCOUNT_NAME/$CONTAINER ...";
        mkdir -p $MOUNT/$AZURE_ACCOUNT_NAME/$CONTAINER
    fi

    echo "Syncing container $CONTAINER ...";
    az storage blob download-batch -d $MOUNT/$AZURE_ACC]OUNT_NAME/$CONTAINER -s $CONTAINER --account-name $AZURE_ACCOUNT_NAME --account-key $AZURE_ACCOUNT_KEY
    echo "";
done
