pipeline {
    agent any

    environment {
        SONARQUBE_ENV = 'SonarQube'   // name configured under Manage Jenkins → Configure System
        SONAR_TOKEN = credentials('SONAR_TOKEN')
        SONAR_HOST_URL = '65.0.94.155:9000' // Note: Protocol (http://) is added in the sh step
        PATH = "/opt/sonar-scanner/bin:$PATH" // Manually adding scanner to PATH
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
                          -Dsonar.host.url=http://65.0.94.155:9000 \ // Added http:// and used variable
                          -Dsonar.login=${SONAR_TOKEN}
                    '''
                }
            }
        }

        stage('Quality Gate') {
            steps {
                // Wait max 2 minutes for SonarQube analysis to complete and check quality gate status
                timeout(time: 2, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
    } // End of stages

    post {
        always {
            echo 'Pipeline completed.'
        }
        success {
            echo 'SonarQube scan completed successfully and passed Quality Gate.'
        }
        failure {
            echo 'Pipeline failed (check logs or Quality Gate status).'
        }
        // Specific status for Quality Gate failure if needed
        // unstable {
        //     echo 'Pipeline unstable: SonarQube Quality Gate failed.'
        // }
    } // End of post
} // End of pipeline
