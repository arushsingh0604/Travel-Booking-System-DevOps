pipeline {
    agent any

    environment {
        SONARQUBE_ENV = 'SonarQube'   // Name configured under Manage Jenkins → Configure System
        SONAR_TOKEN = credentials('SONAR_TOKEN')
        SONAR_HOST_URL = '65.0.94.155:9000'
        PATH = "/opt/sonar-scanner/bin:$PATH"
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
                          -Dsonar.host.url=http://65.0.94.155:9000 \
                          -Dsonar.login=${SONAR_TOKEN}
                    '''
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 2, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline completed.'
        }
        success {
            echo 'SonarQube scan completed successfully.'
            emailext(
                to: 'arushsingh0604@gmail.com',
                subject: "✅ SUCCESS: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """
                <p>Hi Arush,</p>
                <p>The Jenkins pipeline for <b>${env.JOB_NAME}</b> completed successfully.</p>
                <p><b>Build URL:</b> <a href='${env.BUILD_URL}'>${env.BUILD_URL}</a></p>
                <p>Quality Gate passed successfully ✅</p>
                <p>Regards,<br>Jenkins CI</p>
                """,
                mimeType: 'text/html'
            )
        }
        failure {
            echo 'SonarQube scan failed.'
            emailext(
                to: 'arushsingh0604@gmail.com',
                subject: "❌ FAILURE: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """
                <p>Hi Arush,</p>
                <p>The Jenkins pipeline for <b>${env.JOB_NAME}</b> has failed due to a Quality Gate error or pipeline issue.</p>
                <p><b>Build URL:</b> <a href='${env.BUILD_URL}'>${env.BUILD_URL}</a></p>
                <p>Please review the SonarQube dashboard for more details:<br>
                <a href='http://${env.SONAR_HOST_URL}/dashboard?id=Travel-Booking-System'>
                SonarQube Project Dashboard</a></p>
                <p>Regards,<br>Jenkins CI</p>
                """,
                mimeType: 'text/html'
            )
        }
    }
}
