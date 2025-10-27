pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Msocial123/Travel-Booking-System.git'
            }
        }
    }

    post {
        always {
            echo 'Pipeline completed.'
        }
    }
}
