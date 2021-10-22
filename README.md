# jenkins-docker-runner
Dockerfile and docker-compose.yml to quickly spin-up a Jenkins controller + agent

### Requirements:
1. Docker has been downloaded, installed, and running on your machine (https://www.docker.com/products/docker-desktop)
2. Dockerhub account has been created (https://hub.docker.com/) (optional)
3. SSH key pair (see: https://www.jenkins.io/doc/book/using/using-agents/ Generating an SSH key pair)

## Setup
The first time we run the project we have to manually navigate to Jenkins and set everything up. On subsequent runs we can start both the Jenkins controller and agent with one command! 
### Clone Repo
https://github.boozallencsn.com/HUBQACOP/jenkins-docker-runner

### Create Docker Image (Optional)
1. Run the following command from the directory where the Dockerfile is located or specify its location:
`docker build -t=<your-dockerhub-username>/<image-name> .`
(Don't forget the dot - it provides the context of where the Dockerfile is located)
2. push the image to your dockerhub repo
````
docker login
docker push <your-dockerhub-username>/<image-name>
````
replace the current image name with your image in the docker-compose.yml
- **Note**: alternatively, we can uncomment the build node in the docker-compose.yml and run:
````
docker compose build && docker compose up
````
To build and start our agent image and container

### Modify docker-compose.yml 
1. Replace JENKINS_AGENT_SSH_PUBKEY: with your public key
    - run: `cat ~/.ssh/jenkins_agent_key.pub` to get your key

### Start Jenkins Controller (master)
````
docker compose up jenkins-master
````
- You should receive a default password in the console output. 
-  Copy this password


### Navigate to Jenkins Web Interface
````
localhost:8080 
````
- Enter the default password
- select the default plugin installation
- enter 'admin' or whatever login credentials and email you desire

## Stop here (optional)
You now have a fully functional Jenkins controller that you can continue to start and stop with:
````
docker compose up jenkins-master
docker compose down
````

The following steps walk you through creating a jenkins agent to execute jobs.

### Create a Jenkins SSH credential
1. Jenkins dashboard > Manage jenkins (side menu) > Manage Credentials (center menu)
2. Select 'Add credentials' (drop-down menu next to global for jenkins)
3. fill form:
- Kind: SSH Username with private key;
- id: jenkins
- description: The jenkins ssh key
- username: jenkins

- Private Key: select Enter directly, copy and paste your key, and press the Add button to insert your private key 
    - run: `cat ~/.ssh/jenkins_agent_key` to get your key
    - copy the entire key (including the beginning and end phrases)

- Passphrase: fill your passphrase used to generate the SSH key pair and then press OK
![alt text](https://www.jenkins.io/doc/book/resources/node/credentials-3.png)

## Create a Jenkins agent
1. Jenkins dashboard > Manage jenkins (side menu) > Manage Nodes and Clouds (center menu) > New Node (side menu)
2. Fill the Node/agent name: agent1
   - Select the Type: Permanent Agent
   - Remote root directory: /var/jenkins 
   
   - label: agent1 
   
   - usage: Use this node as much as possible
   
   - Launch method; (e.g.: Launch agents via SSH )
   
   - Host; (your local machines IP address - found on Mac at System Preferences > Network, under the **Connected** field)
   
   - Credentials; (e.g.: jenkins )
   
   - Host Key verification Strategy; (e.g.: Manually trusted key verification …​ )
   - Do not check 'Require manual verification...'
   
3. Click save, and the agent will be registered, but offline. 



### Stop Jenkins
Enter `ctrl + c` in the terminal where you started to stop the Jenkins controller -or- enter `docker compose down` from the directory where the docker-compose.yml is located.

### Start the Jenkins Controller + Agent
Run: `docker compose up` to start both the Jenkins controller **AND** the agent node  

**NOTE:** 
use `docker compose up -d` to start everything in 'detached' or 'background' mode. You won't see the console logs, but it will return to the terminal where you can use `docker compose down` to bring everything down.
