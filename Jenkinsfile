pipeline {
    agent any

    environment {
        KUBE_CONFIG_DIR = '/var/lib/jenkins/.kube'
        KUBE_CONFIG_FILE = "${KUBE_CONFIG_DIR}/config"
        KUBE_MASTER_USER = 'root'
        KUBE_MASTER_IP = '10.0.1.64'
        KUBE_MASTER_CONFIG_PATH = "/root/.kube/config"
        PEM_FILE = '/home/ubuntu/linux.pem'
    }

    stages {
        stage('Build Project') {
            steps {
                git url: 'https://github.com/indusharma19/health-care.git', branch: 'master'
                sh 'mvn clean compile'
                sh 'mvn test'
                sh 'mvn package'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh 'docker build -t indu1919/health-care:v1 .'
                    sh 'docker images'
                }
            }
        }

        stage('DockerHub Login') {
            steps {
                withCredentials([string(credentialsId: 'dockerhub-pass', variable: 'dockerpass')]) {
                    sh 'docker login -u indu1919 -p ${dockerpass}'
                }
            }
        }

        stage('Tag and Push Image') {
            steps {
                script {
                    sh 'docker push indu1919/health-care:v1'
                }
            }
        }

        stage('Clone Repository for Ansible') {
            steps {
                git url: 'https://github.com/indusharma19/health-care.git', branch: 'master'
            }
        }

        stage('Add Host Key for Kubernetes Master') {
            steps {
                script {
                    sh '''
                        mkdir -p /var/lib/jenkins/.ssh
                        chmod 700 /var/lib/jenkins/.ssh
                        ssh-keyscan -H ${KUBE_MASTER_IP} >> /var/lib/jenkins/.ssh/known_hosts
                        chmod 644 /var/lib/jenkins/.ssh/known_hosts
                    '''
                }
            }
        }

        stage('Copy Kubernetes Config') {
            steps {
                script {
                    // Ensure correct permissions for the PEM file
                    sh "chmod 400 ${PEM_FILE}"
                    // Create the .kube directory if it doesn't exist
                    sh "mkdir -p ${KUBE_CONFIG_DIR}"
                    // Copy the Kubernetes config file from Kubernetes master to Jenkins server using tar and ssh
                    sh '''
                        ssh -i ${PEM_FILE} -o StrictHostKeyChecking=no ${KUBE_MASTER_USER}@${KUBE_MASTER_IP} "tar -czf - -C /root/.kube config" | tar -xzf - -C ${KUBE_CONFIG_DIR}
                    '''
                    // Check if the file was copied successfully
                    sh "ls -l ${KUBE_CONFIG_FILE}"
                }
            }
        }

        stage('Deploy with Ansible to Kubernetes') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'ansible', keyFileVariable: 'KEYFILE')]) {
                    script {
                        // Set KUBECONFIG environment variable for Ansible
                        withEnv(["KUBECONFIG=${KUBE_CONFIG_FILE}", 'ANSIBLE_HOST_KEY_CHECKING=False']) {
                            sh 'ansible-playbook -i ansible/inventory ansible/ansible-playbook-k8s.yml --key-file $KEYFILE'
                        }
                    }
                }
            }
        }
    }
}
