#!/bin/bash
#
# run this from the top level
#

export AWS_DEFAULT_PROFILE=mark-internal
#EC2_FILES_BUCKET='mark-awsquickstart-test/videoediting'


if [ -z "$AWS_DEFAULT_PROFILE" ]; then
    echo
    echo "AWS_DEFAULT_PROFILE environment variable not set"
    echo
    echo "if you have only 1 default profile use this: "
    echo
    echo "         export AWS_DEFAULT_PROFILE=default"
    echo
    exit
fi
pushd $PWD

TARGET_BUCKET=""

while true; do
    case "$1" in

        "--region")
            REGION=$2
            shift 2
            ;;

        "--target-bucket")
            TARGET_BUCKET=$2
            shift 2
            ;;

        *)
            # default case, no more options
            break
            ;;
    esac
done

echo
echo "region: $REGION, target_bucket: $TARGET_BUCKET"
echo

if [ -n "$TARGET_BUCKET" ] && [ -n "$REGION" ]; then
    echo "publishing to $TARGET_BUCKET"
    aws s3 sync ./ s3://$TARGET_BUCKET --region "$REGION" --exclude ".git/*"  --exclude ".idea/*" --exclude "ci"  --exclude ".gitmodules"  --exclude "*.bash"  --exclude "*.txt"
else
    echo ""
    echo "usage: $0 --target-bucket <bucket-name/path> --region <region>"
    echo ""
fi

popd
