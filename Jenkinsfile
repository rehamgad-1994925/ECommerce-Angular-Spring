pipeline{

  agent any 
  
  parameters{

     string(name: 'awsRegion',  defaultValue: 'us-east-1')
     string(name: 'gitUrl', defaultValue: '' )
     string(name: 'repo',  defaultValue:'')
  }
  stages{
    stage('Checkout') {
            steps {
                checkout scm
            }
    }


    
    stage(build-backend){
          steps{
             script{

                cd ${params.repo}/ecommerencebackend
                mvn clean install
                
             }
          }
       }
    stage(build-frontend){
         steps{
            script{
                cd ${params.repo}/frontend
                npm install
                npm run build
            }
         }
       }

       }
    
    stage (build-deployment) {
        steps{
          script{
            
               cd ${params.repo}/k8s.manifesto
               kubectl apply -f   . 

            
          }
        }
    }

    stage (deploy-infrastrucuture){
       steps{
          script{
            
             cd ${params.repo}
             terraform init
             terraform plan -var="appName=${params.repo}"  -out tfplan
             terraform apply -input=false -auto-approve tfplan
        
          }

          
       }
    }


    stage(upload files to s3){
        steps{
          script{
            cd ${params.repo}
            aws s3 cp ${params.repo}/ecommernecebackend   s3://my-bucket/backend --acl public-read
            aws s3 cp ${params.repo}/frontend    s3://my-bucket/frontend    --acl public-read

          }

        }
    }


  }


















}
