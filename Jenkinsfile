pipeline {
    agent any // Run on any available agent

    stages {
        stage('Checkout') { // Define a stage named 'Checkout'
            steps {
                // Clone the specified Git repository and branch
                git branch: 'main', url: 'https://github.com/Msocial123/Travel-Booking-System.git'
            }
        }
        // Add more stages here (e.g., Build, Test, Deploy)
    }

    post { // Define actions to run after the pipeline finishes
        always { // Always run this block, regardless of pipeline status
            echo 'Pipeline completed.'
        }
    }
}
