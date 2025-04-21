cortex_cli := 'cortex'
CORTEX_API_KEY := `env CORTEX_API_KEY 2>/dev/null || echo ""`
CORTEX_BASE_URL := `env CORTEX_BASE_URL 2>/dev/null|| echo "https://api.getcortexapp.com"`

help:
   @just -l

# Add test entities and Scorecard to Cortex instance
setup: _check load-data workflows _success

_check-vars:
   #!/bin/bash
   if [ -z ${CORTEX_API_KEY+x} ]
   then 
      echo "CORTEX_API_KEY environment variable is not set."
      exit 1
   fi

   if [ -z ${CORTEX_BASE_URL+x} ]
   then 
      echo "CORTEX_BASE_URL environment variable is not set."
      exit
   fi

_check: _check-brew _check-vars _check-cortex _mkdirs

_check-brew:
   @echo "Checking if brew is installed"
   @which brew > /dev/null || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

_check-cortex:
   #!/bin/bash
   echo "checking if cortex CLI can access tenant"
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

# Add workflows for the Learn Cortex entity
workflows: _check
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
      fi
   done
