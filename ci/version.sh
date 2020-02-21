#!/usr/bin/env bash

if [ -n "${CPHP_PR_ID}" ];
then
    echo "pr-${CPHP_PR_ID}"
    exit 0;
fi;

if [[ ${CPHP_GIT_REF} = "refs/tags/"* ]]
then
    echo "${CPHP_GIT_REF:10}"
else
    echo "dev-${CPHP_GIT_REF:11}"
fi;