# jenkins-docker-runner
docker-compose.yml to quickly spin-up a Jenkins server

### Requirements:
1. Docker has been downloaded, installed, and running on your machine (https://www.docker.com/products/docker-desktop)
2. Dockerhub account has been created (https://hub.docker.com/) (optional)


## Setup
The first time we run the project we have to manually navigate to Jenkins and set everything up. On subsequent runs the server configurations will be saved

### Clone Repo
https://github.com/brandonwilliams2/jenkins-runner.git

### Start Jenkins 
````
docker compose up jenkins
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

## Stop Jenkins
You now have a fully functional Jenkins controller that you can start and stop with:
````
docker compose up
docker compose down
````
You can use the Jenkins controller to execute jobs but that is NOT a recommended best practice by Jenkins.
The following steps walk you through creating a Jenkins agent to execute jobs.


## Create a Jenkins agent
1. Jenkins dashboard > Manage jenkins (side menu) > Manage Nodes and Clouds (center menu) > New Node (side menu)
2. Fill the Node/agent name: agent1
   - Select the Type: Permanent Agent
   - Remote root directory: /var/jenkins (where agent config files, etc will be saved) ex /Users/brandonwilliams/jenkins-agent-files
  
 NOTE: create this directory first and give it full read, write, execute permissions: sudo chmod ugo+ rwx "jenkins"
   
   - label: agent1 
   
   - usage: Use this node as much as possible
   
   - Launch method; (e.g.: Launch agent by connecting it to the master)
   
3. Click save, and the agent will be registered, but offline. 
4. Select the newly created agent
5. Download the agent.jar
6. Copy and run the “Run from agent command line:” command from the dir where agent.jar is located

NOTE: Use 'sudo' to give agent the necessary rights to download and store the needed .jars (dependencies). If running on Windows, simply launch the command prompt as Administrator and run the command WITHOUT sudo

ex 
sudo java -jar agent.jar -jnlpUrl http://localhost:8080/computer/Docker1/jenkins-agent.jnlp -secret afb034420ecea40ae7783c236cba08997da5f04c07655c4465fc591390c9a11e -workDir "/Users/brandonwilliams/jenkins"


### Stop Jenkins
Enter `docker compose down` from the directory where the docker-compose.yml is located.
