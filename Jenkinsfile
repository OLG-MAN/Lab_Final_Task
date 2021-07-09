podTemplate(jenkins-slave) {
    node(jenkins-slave) {

        environment{
            DOCKER_USERNAME = credentials('DOCKER_USERNAME')
            DOCKER_PASSWORD = credentials('DOCKER_PASSWORD')
        }
    
        stages {
            stage('Docker login') {
                steps{
                    sh('docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD') 
                }
            }

            stage('Git clone') {
                steps{
                    sh(script: """
                        git clone https://github.com/OLG-MAN/Lab_Final_Task.git
                    """, returnStdout: true) 
                }
            }

            stage('Docker build') {
                steps{
                    sh script: '''
                    #!/bin/bash
                    cd $WORKSPACE/Lab_Final_Task/python_app
                    docker build . --network host -t olegan/testapp:${BUILD_NUMBER}
                    '''
                }
            }

            stage('Docker push') {
                steps{
                    sh(script: """
                        docker push olegan/testapp:${BUILD_NUMBER}
                    """)
                }
            }

            stage('Deploy to TEST') {
                steps{
                    sh script: '''
                    #!/bin/bash
                    cd $WORKSPACE/Lab_Final_Task/
                    curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
                    chmod +x ./kubectl
                    ./kubectl -n test apply -f ./kubernetes/test/configmap.yaml
                    ./kubectl -n test apply -f ./kubernetes/test/secret.yaml
                    cat ./kubernetes/test/deployment.yaml | sed s/10/${BUILD_NUMBER}/g | ./kubectl -n test apply -f -
                    ./kubectl -n test apply -f ./kubernetes/test/service.yaml
                    '''
                }
            }

            stage('Deploy to PROD') {
                steps{
                    input 'Deploy to Production?'
                    milestone(1)
                    sh script: '''
                    #!/bin/bash
                    cd $WORKSPACE/Lab_Final_Task/
                    curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
                    chmod +x ./kubectl
                    ./kubectl -n prod apply -f ./kubernetes/prod/configmap.yaml
                    ./kubectl -n prod apply -f ./kubernetes/prod/secret.yaml
                    cat ./kubernetes/prod/deployment.yaml | sed s/10/${BUILD_NUMBER}/g | ./kubectl apply -f -
                    ./kubectl -n prod apply -f ./kubernetes/prod/service.yaml
                    '''
                }
            }
        }
    }
}