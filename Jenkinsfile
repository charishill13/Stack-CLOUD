pipeline {
    agent any
    environment {
        PATH = "${PATH}:${getTerraformPath()}"
    }
    stages{
         stage('terraform init'){
             steps {
                 //sh "returnStatus: true, script: 'terraform workspace new dev'"
                 sh "terraform init"
         }
         }
         stage('Terraform Destroy') {
              steps {
                script {
                def userInput = input(id: 'confirm', message: 'Destroy all resources?', parameters: [ [$class: 'BooleanParameterDefinition', defaultValue: false, description: 'Terraform Destroy', name: 'confirm'] ])
                tfCmd('destroy', '-auto-approve')
             }
           }
        }  
}
 def getTerraformPath(){
        def tfHome= tool name: 'terraform-14', type: 'terraform'
        return tfHome
    }
white_check_mark
eyes
raised_hands






