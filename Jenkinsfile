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
        string(name: 'DOCKER_IMAGE_TAG', defaultValue: 'v1.0', description: 'Docker image tag')
        string(name: 'REPO_NAME', defaultValue: 'travel-booking-system', description: 'Docker image base name')
        string(name: 'ECR_REPO', defaultValue: '881490098879.dkr.ecr.ap-south-1.amazonaws.com/devops/travel-booking-system', description: 'AWS ECR repository for combined image')
        string(name: 'DOCKERHUB_REPO', defaultValue: 'arushsingh246/travel-booking-system', description: 'DockerHub repository for combined image')
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
        stage('Build Docker Image') {
            steps {
                echo "🐳 Building single Docker image (frontend + backend)..."
                sh """
                    docker build -t ${REPO_NAME}:${DOCKER_IMAGE_TAG} .
                """
            }
        }

        // ---------------- STAGE 5 ----------------
        stage('Security Scan - Trivy') {
            steps {
                echo "🛡 Running Trivy security scan on built Docker image..."
                sh """
                    trivy image ${REPO_NAME}:${DOCKER_IMAGE_TAG} --severity CRITICAL,HIGH --exit-code 1 --ignore-unfixed || exit 1
                """
            }
        }

        // ---------------- STAGE 6 ----------------
        stage('Push to AWS ECR & DockerHub') {
            steps {
                script {
                    echo "🚀 Pushing Docker image to AWS ECR and DockerHub..."

                    // --- AWS ECR ---
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'AWS_CREDS']]) {
                        sh """
                            aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin 881490098879.dkr.ecr.ap-south-1.amazonaws.com

                            docker tag ${REPO_NAME}:${DOCKER_IMAGE_TAG} ${ECR_REPO}:${DOCKER_IMAGE_TAG}
                            docker push ${ECR_REPO}:${DOCKER_IMAGE_TAG}
                        """
                    }

                    // --- DockerHub ---
                    withCredentials([usernamePassword(credentialsId: 'DOCKERHUB_CREDS', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh """
                            echo ${DOCKER_PASS} | docker login -u ${DOCKER_USER} --password-stdin
                            docker tag ${REPO_NAME}:${DOCKER_IMAGE_TAG} ${DOCKERHUB_REPO}:${DOCKER_IMAGE_TAG}
                            docker push ${DOCKERHUB_REPO}:${DOCKER_IMAGE_TAG}
                        """
                    }
                }
            }
        }

        // ---------------- STAGE 7 ----------------
        stage('Compose Validation (Optional)') {
            steps {
                echo "🧩 Validating docker-compose.yml syntax (optional)..."
                sh "docker-compose config || true"
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
                    <p>Docker image <b>${REPO_NAME}:${DOCKER_IMAGE_TAG}</b> pushed to ECR and DockerHub.</p>
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
                    <p>Please review the SonarQube and Trivy scan results for details:</p>
                    <p><a href='http://${env.SONAR_HOST_URL}/dashboard?id=Travel-Booking-System'>SonarQube Dashboard</a></p>
                    <p><b>Build URL:</b> <a href='${env.BUILD_URL}'>${env.BUILD_URL}</a></p>
                    <p>Regards,<br>Jenkins CI</p>
                """,
                mimeType: 'text/html'
            )
        }
    }
}
