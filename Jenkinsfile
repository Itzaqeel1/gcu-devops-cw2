pipeline {
    agent any // Runs on the Jenkins controller or any available agent

    environment {
        DOCKERHUB_CREDENTIALS_ID = '4772' // ID from Jenkins Credentials
        DOCKER_IMAGE_NAME      = "itzaqeel/gcu-cw2-server" // Your DockerHub user/repo
        PROD_SERVER_SSH_CREDS  = 'prod-server-ssh' // ID for SSH credentials to Production Server
        PROD_SERVER_IP         = '18.215.249.26' // Production Server IP
        // KUBE_CONTEXT           = 'minikube' // Assuming kubectl on Prod Server uses minikube context
    }

    stages {
        stage('1. Checkout Code') { // Basic checkout
            steps {
                checkout scm
            }
        }

        stage('2. Build Docker Image') { // Task 3b (+2 marks for Jenkinsfile)
            steps {
                script {
                    // Use build number for unique tag
                    def imageTag = env.BUILD_NUMBER
                    env.FULL_IMAGE_NAME = "${DOCKER_IMAGE_NAME}:${imageTag}"
                    // Build the image using Docker commands available to Jenkins agent
                    sh "docker build -t ${env.FULL_IMAGE_NAME} ."
                }
            }
        }

        stage('3. Test Container Launch') { // Task 3c (+4 marks for Jenkinsfile)
            // Simple test: run container, wait, check if process is running or curl localhost
            steps {
                script {
                    // Run detached
                    sh "docker run -d --name cw2-test-${env.BUILD_NUMBER} -p 8081:8080 ${env.FULL_IMAGE_NAME}"
                    // Wait a few seconds for the node app to start
                    sleep 10
                    // Check if it responds locally (adjust if container needs linking or specific network)
                    // Simple check: Does the process exist? Or check curl.
                    // sh "docker exec cw2-test-${env.BUILD_NUMBER} curl --fail http://localhost:8080"
                    sh "docker ps | grep cw2-test-${env.BUILD_NUMBER}" // Basic check if container is running
                }
            }
            post {
                always {
                    // Cleanup test container
                    sh "docker stop cw2-test-${env.BUILD_NUMBER} || true"
                    sh "docker rm cw2-test-${env.BUILD_NUMBER} || true"
                }
            }
        }

        stage('4. Push Docker Image') { // Task 3d (+4 marks for Jenkinsfile)
            steps {
                // Use Docker Pipeline plugin step with credentials
                withCredentials([usernamePassword(credentialsId: env.DOCKERHUB_CREDENTIALS_ID, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh "docker login -u ${env.DOCKER_USER} -p ${env.DOCKER_PASS}"
                    sh "docker push ${env.FULL_IMAGE_NAME}"
                    // Optional: Tag as latest and push
                    sh "docker tag ${env.FULL_IMAGE_NAME} ${DOCKER_IMAGE_NAME}:latest"
                    sh "docker push ${DOCKER_IMAGE_NAME}:latest"
                    sh "docker logout" // Logout after push
                }
            }
        }

        stage('5. Deploy to Kubernetes') { // Task 3e (+5 marks for Jenkinsfile)
            // Use SSH Agent plugin with Prod Server SSH Credentials to run kubectl remotely
            steps {
                 sshagent (credentials: [env.PROD_SERVER_SSH_CREDS]) {
                    // Connect via SSH and run the kubectl command on the Production Server
                    // The --record flag is useful for rollout history
                    sh """
                    ssh -o StrictHostKeyChecking=no ubuntu@${env.PROD_SERVER_IP} \
                    'kubectl set image deployment/cw2-deployment cw2-container=${env.FULL_IMAGE_NAME} --record'
                    """
                    // Optional: Check rollout status
                    sh """
                    ssh -o StrictHostKeyChecking=no ubuntu@${env.PROD_SERVER_IP} \
                    'kubectl rollout status deployment/cw2-deployment'
                    """
                 }
            }
        }
    } // end stages

    post { // Runs after all stages
        always {
            echo 'Pipeline finished.'
            // Clean up workspace if necessary
            cleanWs()
        }
        success {
            echo 'Pipeline succeeded!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
} // end pipeline
