pipeline {
    agent any

    tools {
        // ✅ Use the correct SonarScanner tool identifier
        hudson.plugins.sonar.SonarRunnerInstallation 'SonarScanner-Latest'
    }

    environment {
        SONARQUBE_ENV = 'SonarQube'   // name as configured in Jenkins → Configure System
        SONAR_TOKEN = credentials('SONAR_TOKEN')
        SONAR_HOST_URL = 'http://65.0.94.155:9000'
    }

    stages {
        stage('Checkout') {
            steps {
                echo "Checking out code from GitHub..."
                git branch: 'main', url: 'https://github.com/Msocial123/Travel-Booking-System.git'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                echo "Running SonarQube analysis..."
                withSonarQubeEnv(env.SONARQUBE_ENV) {
                    sh '''
                        sonar-scanner \
                          -Dsonar.projectKey=Travel-Booking-System \
                          -Dsonar.projectName="Travel Booking System" \
                          -Dsonar.sources=. \
                          -Dsonar.host.url=${SONAR_HOST_URL} \
                          -Dsonar.login=${SONAR_TOKEN}
                    '''
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline completed.'
        }
        success {
            echo 'Pipeline succeeded!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
