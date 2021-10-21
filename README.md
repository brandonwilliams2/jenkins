# jenkins-docker-runner
Dockerfile and docker-compose.yml to quickly spin-up a Jenkins controller + agent

### Requirements:
1. Docker has been downloaded and installed on your machine (https://www.docker.com/products/docker-desktop)
2. Dockerhub account has been created (https://hub.docker.com/)
3. SSH key pair (see: https://www.jenkins.io/doc/book/using/using-agents/ Generating an SSH key pair)

## Setup
The first time we run the project we have manually navigate to Jenkins and set everything up. On subsequent runs we can start both the Jenkins controller and agent with one command! 
### Clone Repo
https://github.boozallencsn.com/HUBQACOP/jenkins-docker-runner

### Create Docker Image (Optional)
1. Run the following command from the directory where the Dockerfile is located or specify it's location:
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
docker compose up --service jenkins-master
````

### Navigate to Jenkins Server Web Interface
````
localhost:8080 
````
### Create a Jenkins SSH credential
1. Jenkins dashboard > Manage jenkins (side menu) > Manage Credentials (center menu)
2. Select 'Add credentials'
3. fill form:
- Kind: SSH Username with private key;
- id: jenkins
- description: The jenkins ssh key
- username: jenkins

- Private Key: select Enter directly, copy and paste your key, and press the Add button to insert your private key 
    - run: `cat ~/.ssh/jenkins_agent_key` to get your key

- Passphrase: fill your passphrase used to generate the SSH key pair and then press OK
![alt text](https://www.jenkins.io/doc/book/resources/node/credentials-3.png)

## Create a Jenkins agent
1. Jenkins dashboard > Manage jenkins (side menu) > Manage Nodes and Clouds (center menu) > New Node (side menu)
2. Fill the Node/agent name and select the type; (e.g. Name: agent1, Type: Permanent Agent)
   
   - Now fill the fields:
   
   - Remote root directory; (e.g.: /var/jenkins )
   
   - label; (e.g.: agent1 )
   
   - usage; (e.g.: Use this node as much as possible)
   
   - Launch method; (e.g.: Launch agents via SSH )
   
   - Host; (your local machines IP address - found on mac at System Preferences > Network, under the **Connected** field)
   
   - Credentials; (e.g.: jenkins )
   
   - Host Key verification Strategy; (e.g.: Manually trusted key verification …​ )
   
3. Click save and the agent will be registered, but offline. Click on it.
4. Click Launch Agent
5. Click Console Logs
6. Look for the message: `Agent successfully connected and online on the last log line.`

### Stop Jenkins
Enter `cntrl + c` in the terminal where you started to stop the Jenkins controller -or- enter `docker compose down` from the directory where the docker-compose.yml is located.

### Start the Jenkins Controller + Agent
Enter `docker compose up` to start both the Jenkins controller and the agent
**NOTE:** 
use `docker compose up -d` to start everything in 'detached' or 'background' mode. You won't see the console logs, but it will return to the terminal where you can use `docker compose down` to bring everything down.
