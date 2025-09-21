pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'surya485/ci-cd-java-app'  // your DockerHub username
        DOCKERHUB_CREDENTIALS = 'dockerhub'       // Jenkins credentials ID for DockerHub
        SONARQUBE = 'MySonarQube'                 // SonarQube server configured in Jenkins
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build & Test') {
            steps {
                sh 'mvn -B clean verify'    // Run tests, fail if tests fail
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

        stage('Docker Build & Push') {
            steps {
                script {
                    docker.withRegistry('', "${DOCKERHUB_CREDENTIALS}") {
                        def img = docker.build("${DOCKER_IMAGE}:${env.BUILD_NUMBER}")
                        img.push()
                        img.push("latest")
                    }
                }
            }
        }

        stage('Deploy (local)') {
            steps {
                script {
                    // Remove existing container if exists
                    sh 'docker rm -f ci-cd-app || true'
                    // Run the container with the pushed image
                    sh 'docker run -d --name ci-cd-app -p 8081:8080 ${DOCKER_IMAGE}:latest'
                }
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
