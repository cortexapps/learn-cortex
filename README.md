# learn-cortex
Repository for setting up test entities and learning how to use Cortex.

We're just kicking the tires on this and have limited content, but if you want to give it try please follow
the directions listed below.

# Pre-requistites
- A Cortex instance.
- A way to import the content in the data folder.  The [Cortex Command Line Interface](https://pypi.org/project/cortexapps-cli/) is recommended.

# Create Cortex entities
- clone this repository on to your machine
- cd to your clone directory
- run `cortex backup import -d data`

# The Learn Cortex entity
You will now have an entity named Learn Cortex in your catalog. 

![image](./img/learn-cortex-entity.png)

Click on the 'Learn Okta' scorecard and expand the failing Scorecard rule
to see instructions on how to set up a dev instance of Okta.

![image](./img/learn-okta-scorecard.png)
