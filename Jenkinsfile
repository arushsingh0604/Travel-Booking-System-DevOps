pipeline {
    agent any

    environment {
        SONARQUBE_ENV = 'SonarQube'   
        SONAR_TOKEN = credentials('SONAR_TOKEN')
        SONAR_HOST_URL = '3.110.187.200:9000'
        PATH = "/opt/sonar-scanner/bin:$PATH"
        AWS_DEFAULT_REGION = 'ap-south-1'
        AWS_CREDENTIALS = credentials('AWS_CREDS')
        DOCKERHUB_CREDENTIALS = credentials('DOCKERHUB_CREDS')
    }

    parameters {
        string(name: 'DOCKER_IMAGE_TAG', defaultValue: 'v1.0', description: 'Docker image tag to use')
        string(name: 'REPO_NAME', defaultValue: 'travel-booking-system', description: 'Base name for Docker images')
        string(name: 'ECR_REPO_FRONTEND', defaultValue: '881490098879.dkr.ecr.ap-south-1.amazonaws.com/devops/travel-booking-system-frontend', description: 'AWS ECR repository for frontend')
        string(name: 'ECR_REPO_BACKEND', defaultValue: '881490098879.dkr.ecr.ap-south-1.amazonaws.com/devops/travel-booking-system-backend', description: 'AWS ECR repository for backend')
        string(name: 'DOCKERHUB_REPO_FRONTEND', defaultValue: 'arushsingh246/travel-booking-system-frontend', description: 'DockerHub repository for frontend')
        string(name: 'DOCKERHUB_REPO_BACKEND', defaultValue: 'arushsingh246/travel-booking-system-backend', description: 'DockerHub repository for backend')
    }

    stages {
        // ---------------- STAGE 1 ----------------
        stage('Checkout Code') {
            steps {
                echo "📥 Checking out code from GitHub..."
                git branch: 'main', url: 'https://github.com/Msocial123/Travel-Booking-System.git'
            }
        }

        // ---------------- STAGE 2 ----------------
        stage('SonarQube Analysis') {
            steps {
                echo "🔍 Running SonarQube analysis..."
                withSonarQubeEnv(env.SONARQUBE_ENV) {
                    sh """
                        sonar-scanner \
                          -Dsonar.projectKey=Travel-Booking-System \
                          -Dsonar.projectName='Travel Booking System' \
                          -Dsonar.sources=. \
                          -Dsonar.host.url=http://3.110.187.200:9000 \
                          -Dsonar.login=${SONAR_TOKEN}
                    """
                }
            }
        }

        // ---------------- STAGE 3 ----------------
        stage('Quality Gate') {
            steps {
                timeout(time: 3, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        // ---------------- STAGE 4 ----------------
        stage('Build Docker Images') {
            steps {
                echo "🐳 Building Docker images for frontend and backend..."
                sh """
                    docker build -t ${REPO_NAME}-frontend:${DOCKER_IMAGE_TAG} ./frontend
                    docker build -t ${REPO_NAME}-backend:${DOCKER_IMAGE_TAG} ./backend
                """
            }
        }

        // ---------------- STAGE 5 ----------------
        stage('Security Scan - Trivy') {
            steps {
                echo "🛡 Running Trivy security scan on built Docker images..."
                sh """
                    trivy image ${REPO_NAME}-frontend:${DOCKER_IMAGE_TAG} --severity CRITICAL,HIGH --exit-code 1 --ignore-unfixed || exit 1
                    trivy image ${REPO_NAME}-backend:${DOCKER_IMAGE_TAG} --severity CRITICAL,HIGH --exit-code 1 --ignore-unfixed || exit 1
                """
            }
        }

        // ---------------- STAGE 6 ----------------
        stage('Push to AWS ECR & DockerHub') {
            steps {
                script {
                    echo "🚀 Pushing Docker images to AWS ECR and DockerHub..."

                    // --- AWS ECR ---
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'AWS_CREDS']]) {
                        sh """
                            aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin 881490098879.dkr.ecr.ap-south-1.amazonaws.com

                            docker tag ${REPO_NAME}-frontend:${DOCKER_IMAGE_TAG} ${ECR_REPO_FRONTEND}:${DOCKER_IMAGE_TAG}
                            docker tag ${REPO_NAME}-backend:${DOCKER_IMAGE_TAG} ${ECR_REPO_BACKEND}:${DOCKER_IMAGE_TAG}

                            docker push ${ECR_REPO_FRONTEND}:${DOCKER_IMAGE_TAG}
                            docker push ${ECR_REPO_BACKEND}:${DOCKER_IMAGE_TAG}
                        """
                    }

                    // --- DockerHub ---
                    withCredentials([usernamePassword(credentialsId: 'DOCKERHUB_CREDS', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh """
                            echo ${DOCKER_PASS} | docker login -u ${DOCKER_USER} --password-stdin

                            docker tag ${REPO_NAME}-frontend:${DOCKER_IMAGE_TAG} ${DOCKERHUB_REPO_FRONTEND}:${DOCKER_IMAGE_TAG}
                            docker tag ${REPO_NAME}-backend:${DOCKER_IMAGE_TAG} ${DOCKERHUB_REPO_BACKEND}:${DOCKER_IMAGE_TAG}

                            docker push ${DOCKERHUB_REPO_FRONTEND}:${DOCKER_IMAGE_TAG}
                            docker push ${DOCKERHUB_REPO_BACKEND}:${DOCKER_IMAGE_TAG}
                        """
                    }
                }
            }
        }

        // ---------------- STAGE 7 ----------------
        stage('Compose Validation (Optional Local Test)') {
            steps {
                echo "🧩 Validating docker-compose.yml syntax..."
                sh "docker-compose config"
            }
        }
    }

    // ---------------- POST ACTIONS ----------------
    post {
        always {
            echo '📦 Pipeline completed.'
        }

        success {
            echo '✅ All checks passed. Build and push successful.'
            emailext(
                to: 'arushsingh0604@gmail.com',
                subject: "✅ SUCCESS: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """
                    <p>Hi Arush,</p>
                    <p>The pipeline for <b>${env.JOB_NAME}</b> completed successfully.</p>
                    <p><b>Build URL:</b> <a href='${env.BUILD_URL}'>${env.BUILD_URL}</a></p>
                    <p>Quality Gate ✅ and Security Scan ✅ passed successfully.</p>
                    <p>Docker images have been pushed to both AWS ECR and DockerHub.</p>
                    <p>Regards,<br>Jenkins CI</p>
                """,
                mimeType: 'text/html'
            )
        }

        failure {
            echo '❌ Pipeline failed due to Quality Gate or Security issue.'
            emailext(
                to: 'arushsingh0604@gmail.com',
                subject: "❌ FAILURE: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """
                    <p>Hi Arush,</p>
                    <p>The pipeline for <b>${env.JOB_NAME}</b> failed.</p>
                    <p>Check SonarQube or Trivy scan results for details:</p>
                    <p><a href='http://${env.SONAR_HOST_URL}/dashboard?id=Travel-Booking-System'>SonarQube Dashboard</a></p>
                    <p><b>Build URL:</b> <a href='${env.BUILD_URL}'>${env.BUILD_URL}</a></p>
                    <p>Regards,<br>Jenkins CI</p>
                """,
                mimeType: 'text/html'
            )
        }
    }
}
