# jenkins-runner
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
```
localhost:8080 
```
- Enter the default password
- select the default plugin installation
- enter 'admin' or whatever login credentials and email you desire

## Stop Jenkins
You now have a fully functional Jenkins controller that you can start and stop with:
```
docker compose up
docker compose down
```
You can use the Jenkins controller to execute jobs but that is NOT a recommended best practice by Jenkins.
The following steps walk you through creating a Jenkins agent to execute jobs.


## Create a Jenkins agent
1. Jenkins dashboard > Manage jenkins (side menu) > Manage Nodes and Clouds (center menu) > New Node (side menu)
2. Fill the Node/agent name: agent1
   - Select the Type: Permanent Agent
   - Remote root directory: where agent config files, etc will be saved ex /Users/brandonwilliams/jenkins-agent-files
  
 NOTE: create this directory first and give Jenkins full read, write, execute permissions: `sudo chmod ugo+ rwx "jenkins"`
   
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


## Add Docker Hub Credentials
1. Click Manage Jenkins > Manage Credentials
2. Make sure ‘Stores scoped to “Jenkin” is selected
3. click global
4. click add credentials from the left menu
5. select ‘username with password’
6. Input your dockerhub username and password, give it and ID (ex. DockerHub) and description
click ‘ok’

Docker hub credentials will be used by Jenkins to push and pull docker images from docker hub.

## Create Jenkins job for building and pushing the test images to docker hub

1. Jenkins > New Item > Pipeline
2. Pipeline > Definition >
    3. Pipeline script from SCM
        4. SCM > Git
            5. Repositories > Repository URL > URL of 'java-selenium-framework' repo
            6. Credentials > add credentials if NOT a public repo
        7. Script Path > Jenkinsfile
        8. Additional Behaviours > Clean before checkout

## Create new Jenkins jobs for pulling and running test images
1. Jenkins > New Item > Pipeline
2. Pipeline > Definition >
    3. Pipeline script from SCM
        4. SCM > Git
            5. Repositories > Repository URL > URL of 'selenium-test-runner' repo
            6. Credentials > add credentials if NOT a public repo
        7. Script Path > Jenkinsfile
        8. Additional Behaviours > Clean before checkout

When Jenkins runs these jobs they will reach out to the .git repo, access the Jenkinsfile ane execute the pipeline stages

### CI/CD 
1. Developers/Test engineers regularly add/modify/commit test cases and push them to the github repo
2. Run the Jenkins job: "Selenium_Test_Builder". This job will reach out to the 'java-selenium-framework' github repo and grab the Jenkinsfile
3. "Selenium_Test_Builder" will then execute the stages from Jenkinsfile script:

    * Stage 1: "Build Jars" – executes `sh "mvn clean package -DskipTests"`
        
        * Jenkins agent will pull the test script project from github and package it into executabe jars
        
    * Stage 2: "Build Image" executes 
    
        * The Jenkins agent will build the test script image according to the instructions in the Dockerfile ```
                                                                                                                sh "docker build -t='brandonwilliams2/java-selenium' ."
                                                                                                                ```
        
    * Stage 3: "Push Image"
    
        * Jenkins agent will use your docker hub credentials securely stored and passed in from Jenkins to login to docker hub and push the updated image to the repo
        
4. Run the Jenkins job "Selenium_Test_Runner" which will reach out to the 'selenium-test-runner' github repo and grab the Jenkisfile

5. "Selenium_Test_Runner" will then execute the stages from Jenkinsfile script:

    * Stage 1: "Pull Latest Image"
    
        * Jenkins agent will pull down the latest test script image with all of the updated project and test jars and dependencies
        
    * Stage 2: "Start Grid"
        
        * Jenkins agent will start the selenium gird containers (hub, chrome, firefox) in background mode (-d option)
            ```
            sh "docker-compose up -d hub chrome firefox --no-color"
            ```
            
    * Stage 3: "Run Tests"
        
        * Jenkins agent will start the test script containers for the services specified in this command
            ```
            sh "docker-compose up search-feature book-flight-feature  --no-color"
            ```
            
        * The docker-compose.yml informs each test script container where the selenium grid is (HUB_HOST), which test suite to run, on which browser.
            
6. Post stages
    * In the post-stage the Jenkins agent will archive the results and bring down all of the containers using:
            ```
            docker compose down
            ```

### Stop Jenkins
Enter `docker compose down` from the directory where the docker-compose.yml is located.

#### NOTE: 
We have seen instances where the Jenkins process continues to run even after the container has been terminated. If the Jenkins container has been stopped but the web interface still displays when you navigate to it, you can manually kill the Jenkins process. 

Search for the running Jenkins process:
```
ps -e | grep jenkins
```
Kill the running process:
```
sudo kill <process-number>
```
