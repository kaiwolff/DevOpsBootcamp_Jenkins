# Jenkins

- Jenkins is an open-source continuous integration tool. Being open-source, it is extremely popular and widely used
- As it reduces the manual steps required to get from writing software to it beign deployedgreatly, software like Jenkins is an essential part of building a DevOps culture
- Huge range of plugins are available, including community-created ones that suit almost any purpose.
- Jenkins can be aimed at a git repository, and will then 
- Jenkins is used to set up pipelines, which run in a series of stages to build a sample of recently pushed changes
- If all tests are passed, these can then be passed on, for example to a dockerhub repository, where they are then ready for deployment
- It is also possible to extend the scope of Jenkins all the way to deployment, or simply to run tests periodically.

- Highly adaptable, and the fact that it is used by a wide variety of huge companies shows that it can be used ot get hte job done.



Development computer has ssh key available, and also a deploy key for git

Jenkins listens to the github and keeps track of any new pushes to the github.

So, need to generate another key that allows jenkins to take the github code

- Good practice is to operate tests on an agent node, which is spun up by the master node. This prevents a bad test from breaking the entire Jenkins server

![](images/Typical_Jenkins_Layout.png)


The basic process will be:

    A developer (in this case, us), adds or changes the code

    The code is pushed to the github repository

    Jenkins notices that a new commit has been pushed to the repo and starts a pipeline, authenticating with the deploy key

To do this, need to set up a webhook:

- Firstly, the settings in jenkins should be to use github

- after that, it is as simple as setting up the webhook in the github settings for the repo
    - you can see the webhook in the settings on this repo (though the instance may be spun down by now
    - The URL to give is the jenkins server's, including port number. Then, add `/github-webhook/` to complete the address

Basically, github will send a POST request to that location, triggering Jenkins to clone the repo and run a build.

So now that this has been tested, a better practice would be to have Jenkins run tests and only merge the changes into main once they are passed.

To do this, this repo will gain a branch called `dev`, which we will get Jenkins to listen to.

We can then create a new job to merge the branches.

`This code should be pushed to dev, but merged into main by Jenkins`


# Summary of Jenkins CI/CD for the Node app

- There are 3 jobs: The first one tests the app, the second one to merge the `dev` branch into `main`, and the third one to connect to an ec2 instance, install dependencies.
- This should leave the app ready to be deployed by simply running `npm start` in the `DevOps_Bootcamp_Jenkins/app` folder

## Pre-Jobs: preparing the github repo

- Need a webhook to let Jenkins know that a push has occured

- Also need to give jenkins permission to merge
    - Do this with a deploy key. Select your github repo
    - Then Settings &rarr; deploy keys
    - Add the public key of an ssh key. This can be generated on your local machine

- With the deply key done, we also need to set up a webhook so Jenkins is informed when something actionable occurs.

- Do this in the Settings, under webhook.
    - Add the IP of your Jenkins server, including port and http prefix. Then, add `/github-webhook/`, which is where Jenkins listens
    - Select the event you want to trigger a new jenkins build and save.



## Job 1: CI-Test:

- The aim of this job is to test whether node app runs

- First, point Jenkins at the correct github repo
    - To do this, select the `GitHub project`. Add the https url of your repo
- Next, set up `Source Code Management`:
    - Select `Git`. Add the ssh url from github, then set up your credentials. You will need the private key portion of the deploy key.
    - Specify the branch to build. We will be using `*/dev` in this example
- As a build trigger, use the `GitHub hook trigger for GITScm polling`. This will make the job listen for POST requests to the server from github.
- Next, the build environment. We will need to provide node & npm bin folder to PATH for our particular build, but basically, anything that is required for the running of a particular app
- durign the build step, we want to execute shell commands. This script looks like so:

```
cd app

npm install
npm test
```

- If this is successful, the app is stable and ready for hte next job. To initiate this automatically, add an option to build another project to the post-build actions. We can select the CI-Merge job once this has been set up. Also make sure this only triggers if the build is stable to avoid merging a broken app into main


## Job 2: CI-Merge
- The setup is similar to the previous jobs. Get it to look at the `dev` branch of your repo.
- This job doesn't actually have any build steps, as the app is already tested
- The action occurs in the post-build steps
- There is an option in jenkins to merge branches. Select `main` and `origin` as the targets
- We also want to run the `CD-job` after a successful build, so that needs to be added to the post-build steps as well (exactly like the previous one)

## Job 3 CD-Job

- This job will be taking the new main repo, so that's where we set up the source control management to look.
- The setup is broadly similar to the first job we set up, but we want to ssh into our instance, clone the git repo, and then run the provisioning script.

- To do this, we need to add the SSH key to get into our ec2 instance to the credentials on Jenkins. 
    - Under `build Environment`, sleect SSH Agent, add the key. **ADD THIS MANUALLY TO YOUR JENKINS CREDENTIALS. MAKE SURE TO NEVER EVER PUSH KEYS TO GITHUB**

- The shell comands used in the execute shell block look as follows:

```
#ssh into ec2
#update and upgrade
# run provisioning script or isntall nginx to test
#scp to copy data from github to ec2
ssh -A -o "StrictHostKeyChecking=no" ubuntu@34.255.4.162 << EOF


# Make sure starting directory is empty, then repopulate with git repo

sudo rm -rf *
git clone https://github.com/kaiwolff/DevOpsBootcamp_Jenkins.git

# Should now have a folder called DevOpsBootcamp_Jenkins

cd DevOpsBootcamp_Jenkins/

sudo chmod +x provision_app.sh
sudo ./provision_app.sh
```

- Congrats you now just need to run `npm start` for the app to become operational (for now, the DB server is assumed to be set up separately on a target IP)