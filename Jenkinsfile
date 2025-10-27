pipeline {
    agent any // Run on any available agent

    environment {
        SONARQUBE_ENV = 'SonarQube'          // Jenkins SonarQube server configuration name (from Configure System)
        SONAR_TOKEN = credentials('SONAR_TOKEN') // Jenkins secret text credential ID for the SonarQube token
        // !!! IMPORTANT: Define the URL of your SonarQube server here !!!
        SONAR_HOST_URL = 'http://your-sonarqube-server-ip:9000'
        // If your project requires Java 17 and Maven for Sonar analysis, ensure they are available on the agent
        // Or add tools section:
        // JAVA_HOME = tool 'jdk17' // Assuming 'jdk17' is configured in Global Tool Configuration
        // MAVEN_HOME = tool 'maven3' // Assuming 'maven3' is configured
        // PATH = "${JAVA_HOME}/bin:${MAVEN_HOME}/bin:${env.PATH}"
    }

    stages {
        stage('Checkout') { // Define a stage named 'Checkout'
            steps {
                // Clone the specified Git repository and branch
                echo "Checking out code from GitHub..."
                git branch: 'main', url: 'https://github.com/Msocial123/Travel-Booking-System.git'
            }
        }

        // CORRECTED: SonarQube stage is now directly under the main 'stages' block
        stage('SonarQube Analysis') {
            steps {
                echo "Running SonarQube analysis..."
                // Use withSonarQubeEnv to configure scanner connection based on Jenkins settings
                withSonarQubeEnv(env.SONARQUBE_ENV) {
                    // Execute the sonar-scanner command
                    // Assumes sonar-scanner is installed and in PATH on the agent
                    // Or use Maven/Gradle goals if it's a Maven/Gradle project
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

    } // End of main stages block

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
} //
