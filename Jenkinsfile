pipeline {
    agent any // Run on any available agent
    tools {
        sonarqube 'SonarScanner-Latest' // Use the name you configured
    }

    environment {
        SONARQUBE_ENV = 'SonarQube'          // Jenkins SonarQube server configuration name
        SONAR_TOKEN = credentials('SONAR_TOKEN') // Jenkins secret text credential ID
        SONAR_HOST_URL = 'http://65.0.94.155:9000' // URL of your SonarQube server
        // Add tools section if needed (see previous examples if sonar-scanner isn't globally available)
        // tools { sonarqube 'SonarScanner-Latest' } // Uncomment and configure if needed
    }

    // *** CORRECTED: Added the main 'stages' block here ***
    stages {

        // *** CORRECTED: Added the Checkout stage (assuming you still need it) ***
        stage('Checkout') {
            steps {
                echo "Checking out code from GitHub..."
                // Using the original project repo, change if needed
                git branch: 'main', url: 'https://github.com/Msocial123/Travel-Booking-System.git'
            }
        }

        // *** CORRECTED: SonarQube stage is now INSIDE the main 'stages' block ***
        stage('SonarQube Analysis') {
            steps {
                echo "Running SonarQube analysis..."
                // Use withSonarQubeEnv to configure scanner connection based on Jenkins settings
                withSonarQubeEnv(env.SONARQUBE_ENV) {
                    // Execute the sonar-scanner command
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
        // Add more stages here (e.g., Build, Test, Deploy)

    } // *** CORRECTED: This brace now correctly closes the main 'stages' block ***

    post { // Define actions to run after the pipeline finishes
        always { // Always run this block, regardless of pipeline status
            echo 'Pipeline completed.'
        }
        success {
            echo 'Pipeline succeeded!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
} // End of pipeline
