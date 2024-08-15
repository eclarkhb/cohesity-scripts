AZURE_ACCOUNT_NAME=
AZURE_ACCOUNT_KEY=
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
                                                                                az storage blob download-batch -d $MOUNT/$AZURE_ACCOUNT_NAME/$CONTAINER -s $CONTAINER --account-name $AZURE_ACCOUNT_NAME --account-key $AZURE_ACCOUNT_KEY
                                                                                    echo "";
                                                                                    done
