pipeline {
  agent any

  environment {
    DOCKER_IMAGE = 'your-dockerhub-username/ci-cd-java-app'
    DOCKERHUB_CREDENTIALS = 'dockerhub'        // credentials ID in Jenkins
    SONARQUBE = 'MySonarQube'                  // SonarQube name in Jenkins config
  }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Build & Test') {
      steps {
        sh 'mvn -B clean verify'    // run tests; fails if tests fail
      }
    }

    stage('SonarQube Analysis') {
      steps {
        withSonarQubeEnv("${env.SONARQUBE}") {
            sh 'mvn -B sonar:sonar -Dsonar.projectKey=ci-cd-java-app'
            }
      }
    }

    stage('Quality Gate') {
      steps {
        timeout(time: 5, unit: 'MINUTES') {
          waitForQualityGate abortPipeline: true
        }
      }
    }

stage('Deploy (local)') {
    steps {
        script {
            // Remove existing container if exists
            sh 'docker rm -f ci-cd-app || true'
            
            // Run the container with the correct image
            sh 'docker run -d --name ci-cd-app -p 8080:8080 surya485/ci-cd-java-app:latest'
        }
    }
}


    stage('Deploy (local)') {
      steps {
        sh """
          docker rm -f ci-cd-app || true
          docker run -d --name ci-cd-app -p 8080:8080 ${DOCKER_IMAGE}:latest
        """
      }
    }
  }

  post {
    always {
      junit '**/target/surefire-reports/*.xml'
      archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
    }
  }
}
