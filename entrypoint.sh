#!/bin/bash
export AWS_REGION=$INPUT_AWS_REGION
export AWS_DEFAULT_REGION=$INPUT_AWS_REGION
export AWS_ACCESS_KEY_ID=$INPUT_AWS_KEY
export AWS_SECRET_ACCESS_KEY=$INPUT_AWS_SECRET
echo $AWS_REGION
echo $AWS_DEFAULT_REGION
echo $INPUT_PATH
echo $INPUT_LOCAL_PATH
echo $INPUT_AWS_REGION


if [ "$INPUT_UPLOAD_OR_DOWNLOAD" == 'download' ]; then
        echo "Downloading Cache file from s3 bucket $INPUT_BUCKET with path $INPUT_PATH and backup path $INPUT_BACKUP_PATH"
        aws s3 ls s3://$INPUT_BUCKET$INPUT_PATH
        COUNT="$(AWS_REGION=$INPUT_AWS_REGION AWS_ACCESS_KEY_ID=$INPUT_AWS_KEY AWS_SECRET_ACCESS_KEY=$INPUT_AWS_SECRET aws s3 ls s3://$INPUT_BUCKET$INPUT_PATH | wc -l )"
        echo $COUNT
        if [ $COUNT  == 0 ]; then
            AWS_REGION=$INPUT_AWS_REGION AWS_ACCESS_KEY_ID=$INPUT_AWS_KEY AWS_SECRET_ACCESS_KEY=$INPUT_AWS_SECRET aws s3 ls s3://$INPUT_BUCKET$INPUT_BACKUP_PATH
            echo "No items found in primary cache dir, going to secondary"
            COUNT="$(AWS_REGION=$INPUT_AWS_REGION AWS_ACCESS_KEY_ID=$INPUT_AWS_KEY AWS_SECRET_ACCESS_KEY=$INPUT_AWS_SECRET aws s3 ls s3://$INPUT_BUCKET$INPUT_BACKUP_PATH | wc -l )"
            echo "Downloading Cache file from secondary s3 bucket $INPUT_BUCKET with path $INPUT_BACKUP_PATH and backup path $INPUT_BACKUP_PATH"
            echo $COUNT
            if [ $COUNT  == 0 ]; then
                echo "Failed to find any cache to download"
                exit 0;
            fi
            echo "Downloading backup cache to $INPUT_LOCAL_PATH"
            AWS_REGION=$INPUT_AWS_REGION AWS_ACCESS_KEY_ID=$INPUT_AWS_KEY AWS_SECRET_ACCESS_KEY=$INPUT_AWS_SECRET aws s3 sync s3://$INPUT_BUCKET$INPUT_PATH $INPUT_LOCAL_PATH
            echo "Cache downloaded"
            exit 0;
        fi
        echo "Downloading cache to $INPUT_LOCAL_PATH"
        AWS_REGION=$INPUT_AWS_REGION AWS_ACCESS_KEY_ID=$INPUT_AWS_KEY AWS_SECRET_ACCESS_KEY=$INPUT_AWS_SECRET aws s3 sync s3://$INPUT_BUCKET$INPUT_PATH $INPUT_LOCAL_PATH
        echo "Cache downloaded"
        exit 0;
fi

if [ "$INPUT_UPLOAD_OR_DOWNLOAD" == 'upload' ]; then
        echo "Uploading Cache files at $INPUT_LOCAL_PATH to s3 bucket $INPUT_BUCKET with path $INPUT_PATH"
        AWS_REGION=$INPUT_AWS_REGION AWS_ACCESS_KEY_ID=$INPUT_AWS_KEY AWS_SECRET_ACCESS_KEY=$INPUT_AWS_SECRET aws s3 sync $INPUT_LOCAL_PATH s3://$INPUT_BUCKET$INPUT_PATH
        exit 0;
fi

echo "Command $INPUT_UPLOAD_OR_DOWNLOAD not found, must be upload or download"
exit 1;