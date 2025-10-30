pipeline {
    agent any

    environment {
        SONARQUBE_ENV = 'SonarQube'
        SONAR_TOKEN = credentials('SONAR_TOKEN')
        SONAR_HOST_URL = '13.235.242.71:9000'
        PATH = "/opt/sonar-scanner/bin:$PATH"
        AWS_DEFAULT_REGION = 'ap-south-1'
        AWS_CREDENTIALS = credentials('AWS_CREDS')
        DOCKERHUB_CREDENTIALS = credentials('DOCKERHUB_CREDS')
    }

    parameters {
        string(name: 'DOCKER_IMAGE_TAG', defaultValue: 'v1.0', description: 'Docker image tag')
        string(name: 'REPO_NAME', defaultValue: 'travel-booking-system', description: 'Docker image base name')
        string(name: 'ECR_REPO', defaultValue: '881490098879.dkr.ecr.ap-south-1.amazonaws.com/devops/travel-booking-system', description: 'AWS ECR repository')
        string(name: 'DOCKERHUB_REPO', defaultValue: 'arushsingh246/travel-booking-system', description: 'DockerHub repository')
    }

    stages {
        stage('Checkout Code') {
            steps {
                echo "📥 Checking out code..."
                git branch: 'main', url: 'https://github.com/Msocial123/Travel-Booking-System.git'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                echo "🔍 Running SonarQube analysis..."
                withSonarQubeEnv(env.SONARQUBE_ENV) {
                    sh """
                        sonar-scanner \
                          -Dsonar.projectKey=Travel-Booking-System \
                          -Dsonar.projectName='Travel Booking System' \
                          -Dsonar.sources=. \
                          -Dsonar.host.url=http://13.235.242.71:9000 \
                          -Dsonar.login=${SONAR_TOKEN}
                    """
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 3, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "🐳 Building Docker image..."
                sh """
                    docker build --no-cache -t ${REPO_NAME}:${DOCKER_IMAGE_TAG} .
                """
            }
        }

        stage('Security Scan - Trivy') {
            steps {
                echo "🛡 Running Trivy security scan..."
                sh """
                    trivy image --exit-code 0 --severity CRITICAL,HIGH --ignore-unfixed ${REPO_NAME}:${DOCKER_IMAGE_TAG} || true
                """
            }
        }

        stage('Push to AWS ECR & DockerHub') {
            steps {
                script {
                    echo "🚀 Pushing Docker image to ECR and DockerHub..."

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

        stage('Compose Validation (Optional)') {
            steps {
                echo "🧩 Validating docker-compose.yml..."
                sh "docker-compose config || true"
            }
        }
    }

    post {
        always {
            echo '📦 Pipeline completed.'
        }
        success {
            echo '✅ All checks passed.'
            emailext(
                to: 'arushsingh0604@gmail.com',
                subject: "✅ SUCCESS: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """
                    <p>Hi Arush,</p>
                    <p>The pipeline for <b>${env.JOB_NAME}</b> completed successfully.</p>
                    <p>Build URL: <a href='${env.BUILD_URL}'>${env.BUILD_URL}</a></p>
                    <p>Docker image <b>${REPO_NAME}:${DOCKER_IMAGE_TAG}</b> pushed to ECR & DockerHub.</p>
                    <p>Regards,<br>Jenkins CI</p>
                """,
                mimeType: 'text/html'
            )
        }
        failure {
            echo '❌ Pipeline failed.'
            emailext(
                to: 'arushsingh0604@gmail.com',
                subject: "❌ FAILURE: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """
                    <p>Hi Arush,</p>
                    <p>The pipeline for <b>${env.JOB_NAME}</b> failed.</p>
                    <p>Check SonarQube and Trivy for details.</p>
                    <p><a href='${SONAR_HOST_URL}/dashboard?id=Travel-Booking-System'>Sonar Dashboard</a></p>
                """,
                mimeType: 'text/html'
            )
        }
    }
}
