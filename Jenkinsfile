pipeline {
    agent any
    
    tools {
        nodejs 'node21'
    }
    
    environment {
        SCANNER_HOME = tool 'sonar-scanner'
        ECR_REGISTRY = '394952106077.dkr.ecr.ap-northeast-2.amazonaws.com/gomugomdori'
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION = "ap-northeast-2"
    }

    stages {
        stage('Git Checkout') {
            steps {
                git branch: 'main', credentialsId: 'GITHUB_TOKEN', url: 'https://github.com/gomugomdori/gomapp.git'
            }
        }
        stage('Install Package Dependencies') {
            steps {
                sh 'npm install'
            }
        }
        stage('Trivy FS Scan') {
            steps {
                sh 'trivy fs --format table -o fs-report-${BUILD_NUMBER}.html .'
            }
        }
        stage('SonarQube') {
            steps {
                withSonarQubeEnv('sonar') {
                    sh '${SCANNER_HOME}/bin/sonar-scanner -Dsonar.projectKey=gomapp -Dsonar.projectName=gomapp'
                }   
            }
        }
        stage('Docker Build & Tag') {
            steps {
                // ECR 로그인
                sh "aws ecr get-login-password | docker login --username AWS --password-stdin ${ECR_REGISTRY}"
                // Docker 이미지 빌드 및 태그
                sh "docker build -t ${ECR_REGISTRY}/gomapp:${BUILD_NUMBER} ."
                sh "docker tag ${ECR_REGISTRY}/gomapp:${BUILD_NUMBER} ${ECR_REGISTRY}/gomapp:latest"
            }
        }
        stage('Trivy Image Scan') {
            steps {
                sh 'trivy image --format table -o image-report-${BUILD_NUMBER}.html ${ECR_REGISTRY}/gomapp:${BUILD_NUMBER}'
            }
        }
        stage('Docker Push Image') {
            steps {
                // ECR 로그인
                sh "aws ecr get-login-password | docker login --username AWS --password-stdin ${ECR_REGISTRY}"
                withDockerRegistry(credentialsId: "${REGISTRY_CREDENTIALS_ID}", url: "${ECR_REGISTRY}") {
                    // Docker 이미지 푸시
                    sh "docker push ${ECR_REGISTRY}/gomapp:${BUILD_NUMBER}"
                    sh "docker push ${ECR_REGISTRY}/gomapp:latest"
                }
            }
        }
    }
    post {
	always {
	    archiveArtifacts artifacts: '*.html', fingerprint: true
        //cleanWs()
	}
        success {
	    slackSend (color: '#36A64F', message: "SUCCESS: GOMAPP (version : ${BUILD_NUMBER}) CI / CD completed successfully.")
        }
        failure {
	    slackSend (color: '#FF0000', message: "FAILURE: GOMAPP (version : ${BUILD_NUMBER}) CI / CD failed. Check Jenkins logs for more details.")
        }
    }
}
