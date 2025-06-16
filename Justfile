cortex_cli := 'cortex'

export CORTEX_API_KEY := env('CORTEX_API_KEY')
export CORTEX_BASE_URL := env('CORTEX_BASE_URL', "https://api.getcortexapp.com")
export CORTEX_EMAIL := env('CORTEX_EMAIL')
export GH_PAT := env('GH_PAT')

brew := require("brew")
cortex := require("cortex")
jq := require("jq")
yq := require("yq")

@help:
   just -l
   echo ""
   echo "Details"
   echo "The setup recipe requires the following environment variables to be set:"
   echo "- CORTEX_API_KEY  - must have edit entity permission at a minimum, typically will be an admin key"
   echo "- CORTEX_BASE_URL - API endpoint, defaults to https://api.getcortexapp.com"
   echo "- CORTEX_EMAIL    - the user's cortex email address; will be used to assign as owner of the Learn Cortex entity"
   echo "- GH_PAT          - a GitHub personal token that allows read/write access to github.com/cortexapps"

# Add test entities and Scorecard to Cortex instance
setup: load-data _success

_success:
   @echo "SUCCESS!"
   @echo "Login to your tenant and navigate to your Learn Cortex entity to starting learning Cortex."

# Install a single Cortex Scorecard file
scorecard file:
   {{cortex_cli}} scorecard create -f {{file}}

# Load data from 'data' directory into Cortex
load-data: _github
   @echo "Adding data to tenant"
   {{cortex_cli}} backup import -d data

   @cat data/catalog/learn-cortex.yaml | yq -e ".info.x-cortex-owners = [{ \"email\": \"${CORTEX_EMAIL}\", \"type\": \"EMAIL\" }]" | cortex catalog create -f- > /dev/null 2>&1
   
# Add secrets needed for the Learn Cortex entity
_github:
   #!/bin/bash

   cortex integrations github list | jq -r ".configurations[].alias" | grep -e "cortex-prod\$" > /dev/null
   if [[ $? -ne 0 ]]; then
      cortex integrations github add-personal -a "cortex-prod" --access-token ${GH_PAT}
   fi
