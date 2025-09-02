# learn-cortex
Repository for setting up test entities and learning how to use Cortex.

We're just kicking the tires on this and have limited content, but if you want to give it try please follow
the directions listed below.

# Pre-requisites
- A Cortex workspace and a Cortex [Personal token](https://docs.cortex.io/configure/settings/api-keys/personal-tokens).

# Installation
```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/cortexapps/learn-cortex/HEAD/scripts/install.sh)"
```

# The Learn Cortex entity
Run `just setup` to add Learn Cortex entities to your Cortex workspace. 

You will now have an entity named `Learn Cortex` in your catalog. 

![image](./img/learn-cortex-entity.png)

Click on the 'Learn Okta' scorecard and expand the failing Scorecard rule
to see instructions on how to set up a dev instance of Okta.

![image](./img/learn-okta-scorecard.png)

# Contributing
It is hoped that this will be a group-sourced project.  Please fix any errors and add new content using the available workflows
in your sandbox.

# Workflows
There are several workflows that will be available from the Learn Cortex entity:
- **Learn Cortex - create Scorecard**

    This will create a Learn Cortex scorecard from a template in your sandbox.  The intent is that you would add markdown
    to the CQL rule in the Learned level to help educate users on a topic.

- **Learn Cortex - publish Scorecard**

    This will publish a Learn Cortex scorecard from your sandbox to git.
    A Slack message will be posted to #learn-cortex alerting users to new content in the repository.

- **Learn Cortex - install Scorecard**

    Install a Learn Cortex scorecard from the learn-cortex repository.  This allows you to add new content using a workflow.
    Alternatively, you can run update your git checkout and run 'just'.


### **Additional setup needed to run these workflows:**
- Setup Cortex Github integration: https://docs.cortex.io/ingesting-data-into-cortex/integrations/github
    - note: this should already be handled by running the previous command ```just setup```
    - make sure to name github configuration "cortex-prod" (this name is referenced in the "Alias" value in the workflow Github requests)
 
- Create new Cortex API key with "User" role: https://docs.cortex.io/settings/api-keys
    - add this Cortex API key as a new secret named "cortex_api_key": https://docs.cortex.io/settings/api-keys/secrets (this name is referenced in the "Authorization" header of the workflow Cortex API requests)
      

