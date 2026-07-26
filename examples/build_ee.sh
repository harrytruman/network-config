# author: Jason Dickerson - Red Hat
# desc: This script will automate the building of Execution Environments (EEs) and uploading them to Automation Hub.
#!/bin/bash

BASE_DIR=/opt/exec_envs/
PAH={{ pah.fqdn.com }}
EE_NAME=ee-network
EE_VERSION=1.0
EE_VERBOSITY=3

# podman pull registry.redhat.io/ansible-automation-platform-27/ee-supported-rhel9:latest
podman pull registry.redhat.io/ansible-automation-platform-27/ee-minimal-rhel9:2.16

cd ${BASE_DIR}${EE_NAME}
rm -rf context &> /dev/null

ansible-builder build --verbosity ${EE_VERBOSITY} --prune-images --tag ${EE_NAME}:${EE_VERSION} --tag ${EE_NAME}:latest
# if [ $? -eq 0 ] ; then
#   podman push localhost/${EE_NAME}:latest docker://${PAH}/${EE_NAME}:${EE_VERSION}
#   podman push localhost/${EE_NAME}:latest docker://${PAH}/${EE_NAME}:latest
# fi

# podman save --output ${EE_NAME}-${EE_VERSION}.tar localhost/${EE_NAME}:${EE_VERSION}
# gzip ${EE_NAME}-${EE_VERSION}.tar

rm -rf context &> /dev/null
