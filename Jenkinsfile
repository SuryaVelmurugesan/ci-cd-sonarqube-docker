pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'surya485/ci-cd-java-app'   // your DockerHub repo
        DOCKERHUB_CREDENTIALS = 'dockerhub'        // Jenkins credentials ID for DockerHub
        SONARQUBE = 'MySonarQube'                  // SonarQube server configured in Jenkins
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build & Test') {
            steps {
                sh 'mvn -B clean verify'    // Clean + build + test
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
                    def img = docker.build("${DOCKER_IMAGE}:${env.BUILD_NUMBER}")

                    // Try pushing to Docker Hub, but don’t fail the whole pipeline if login/push fails
                    try {
                        docker.withRegistry('https://index.docker.io/v1/', "${DOCKERHUB_CREDENTIALS}") {
                            img.push()
                            img.push("latest")
                        }
                    } catch (err) {
                        echo "⚠️ Docker push failed, continuing with local image. Error: ${err}"
                    }
                }
            }
        }

        stage('Deploy (local)') {
            steps {
                script {
                    sh '''
                        # Remove existing container if it exists
                        docker rm -f ci-cd-app || true

                        # Run container from local build (latest tag will exist locally even if push failed)
                        docker run -d --name ci-cd-app -p 8082:8080 surya485/ci-cd-java-app:latest
                    '''
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
