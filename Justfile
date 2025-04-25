cortex_cli      := 'cortex'

help:
   @just -l
   @echo ""
   @echo "Details"
   @echo "The setup recipe requires the following environment variables to be set:"
   @echo "- CORTEX_API_KEY  - must have edit entity permission at a minimum, typically will be an admin key"
   @echo "- CORTEX_BASE_URL - API endpoint, defaults to https://api.getcortexapp.com"
   @echo "- CORTEX_EMAIL    - the user's cortex email address; will be used to assign as owner of the Learn Cortex entity"
   @echo ""
   @echo "The workflows recipe requires the following environment variables to be set:"
   @echo "- GH_PAT  - a GitHub personal token that allows read/write access to github.com/cortexapps"

# Add test entities and Scorecard to Cortex instance
setup: _check load-data _success

_check-vars:
   #!/bin/bash

   echo "Checking environment variables"

   if [[ -z "${CORTEX_API_KEY}" ]]; then
      echo ""
      echo "ERROR: CORTEX_API_KEY environment variable is not set."
      echo "------------------------------------------------------"
      echo "Please set environment variable CORTEX_API_KEY and retry."
      echo "Refer to https://docs.cortex.io/docs/walkthroughs/workspace-settings/personal-tokens for details on creating a personal token"
      echo "Example: export CORTEX_API_KEY=<your personal token>"
      echo ""
      exit 1
   fi

   if [[ -z "${CORTEX_EMAIL}" ]]; then
      echo ""
      echo "ERROR: CORTEX_EMAIL environment variable is not set."
      echo "----------------------------------------------------"
      echo "Please set environment variable CORTEX_EMAIL and retry."
      echo "It will be used as the owner of the Learn Cortex entity"
      echo "Example: export CORTEX_EMAIL=joe@example.com"
      echo ""
      exit 1
   fi

   CORTEX_BASE_URL=${CORTEX_BASE_URL:-https://api.getcortexapp.com}

_check-pat:
   #!/bin/bash

   echo "Checking if GitHub PAT environment variable is set"

   if [[ -z "${GH_PAT}" ]]; then
      echo ""
      echo "ERROR: GH_PAT environment variable is not set."
      echo "------------------------------------------------------"
      echo "This setup script will create a GitHub Personal token integration in Cortex."
      echo "It requires a GitHub Personal Access Token to be set as an environment variable."
      echo "Refer to https://docs.cortex.io/docs/reference/integrations/github#how-to-configure-github-with-cortex"
      echo "for details on creating the token."
      echo ""
      echo "Once set, copy the content of the token and use it to set an environment variable as follows:"
      echo "export GH_PAT=yourTokenValue"
      echo ""
      exit 1
   fi


_check: _check-brew _check-jq _check-yq _check-vars _check-cortex _mkdirs

_check-brew:
   @echo "Checking if brew is installed"
   @which brew > /dev/null || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

_check-jq:
   @echo "Checking if jq is installed"
   @which jq > /dev/null || brew install jq

_check-yq:
   @echo "Checking if yq is installed"
   @which yq > /dev/null || brew install yq

_check-cortex:
   #!/bin/bash
   echo "Checking if cortex CLI can access tenant"
   {{cortex_cli}} audit-logs get -p 0 -z 1 > /dev/null 2>&1
   if [[ $? -ne 0 ]]; then
      echo "ERROR: Unable to access tenant with Cortex CLI."
      echo "-----------------------------------------------"
      echo "Check API key in ~/.cortex/config under the [default] section."
      echo "To debug: run {{cortex_cli}} audit-logs get -o 0 -z 1"
      exit 1
   fi

_mkdirs:
   #!/bin/bash
   if [[ ! -d data/teams ]]; then
      mkdir data/teams
   fi
   if [[ ! -d data/resource-definitions ]]; then
      mkdir data/resource-definitions
   fi

_success:
   @echo "SUCCESS!"
   @echo "Login to your tenant and navigate to your Learn Cortex entity to starting learning Cortex."

# Install a single Cortex Scorecard file
scorecard file: _check
   {{cortex_cli}} scorecard create -f {{file}}

# Load data from 'data' directory into Cortex
load-data: _check
   @echo "Adding data to tenant"
   @{{cortex_cli}} backup import -d data > /dev/null 2>&1

   @cat data/catalog/learn-cortex.yaml | yq -e ".info.x-cortex-owners = [{ \"name\": \"${CORTEX_EMAIL}\", \"type\": \"EMAIL\" }]" | cortex catalog create -f- > /dev/null 2>&1
   

# Add workflows for the Learn Cortex entity
workflows: _check _github
   #!/bin/bash
   for workflow in $(ls -1 data/workflows)
   do
      status_code=$(\
            curl \
            -s \
            -w "%{http_code}" \
            -X POST \
            --data-binary @data/workflows/${workflow} \
            -H "Authorization: Bearer ${CORTEX_API_KEY}" \
            -H "Content-Type: application/yaml" \
            -o /dev/null \
            "${CORTEX_BASE_URL}/api/v1/workflows")
      if [ $status_code -ne 200 ]; then
        echo "curl failed with HTTP code $status_code"
        exit 1
      else
        echo "Added workflow: ${workflow}"
      fi
   done

# Add secrets needed for the Learn Cortex entity
_github: _check-pat
   #!/bin/bash

   cortex integrations github get-personal -a "cortex - prod" > /dev/null 2>&1
   if [[ $? -ne 0 ]]; then
      envsubst < data/integrations/github/pat-configuration-json.tmpl | cortex integrations github add-personal -f-
   fi
