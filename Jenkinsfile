pipeline {
    
    agent any // Run on any available agent
    
    environment {
        SONARQUBE_ENV = 'SonarQube'      // Jenkins SonarQube server name
        SONAR_TOKEN = credentials('SONAR_TOKEN') // Jenkins credential ID
    }


    stages {
        stage('Checkout') { // Define a stage named 'Checkout'
            steps {
                // Clone the specified Git repository and branch
                git branch: 'main', url: 'https://github.com/Msocial123/Travel-Booking-System.git'
            }
        }
        // Add more stages here (e.g., Build, Test, Deploy)
         stages {
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv("${SONARQUBE_ENV}") {
                    sh '''
                        sonar-scanner \
                        -Dsonar.projectKey=Travel-Booking-System \
                        -Dsonar.projectName="Travel Booking System" \
                        -Dsonar.sources=. \
                        -Dsonar.host.url=$SONAR_HOST_URL \
                        -Dsonar.login=$SONAR_TOKEN
                    '''
                }
            }
        }
    }

    }

    post { // Define actions to run after the pipeline finishes
        always { // Always run this block, regardless of pipeline status
            echo 'Pipeline completed.'
        }
    }
}
