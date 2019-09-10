def branchName = "delete-me"

def images = ['terra-jupyter-base', 'terra-jupyter-bioconductor', 'terra-jupyter-hail', 'terra-jupyter-python', 'terra-jupyter-r']

def getImages() {
  def images = "cat imageDirs.txt".execute().text.trim().split('\n')
  return images
}

pipeline {
   agent { label 'node210' }

   stages {
     
    stage('Git') {
      steps {
        git credentialsId: 'jenkins-ssh-github', url: 'git@github.com:DataBiosphere/terra-docker.git', branch: 'jc-jenkinsfile'
      }
    }

    stage('Build Images') {
      steps {
        script {
          def images = getImages()
          println(images)
        }
      }
    }

    // stage('Env Test') {
    //   steps {
    //     sh """
    //     A=1
    //     echo $A
    //     """
    //   }
    // }
     
    // stage('Test') {
    //   steps {
    //     sshagent(['jenkins-ssh-github']) {
    //       sh """
    //         echo $branchName-${BUILD_NUMBER}
    //         git checkout -b $branchName-${BUILD_NUMBER}
    //         git add temp.txt
    //         git commit -m "test commit"
    //         git push origin $branchName-${BUILD_NUMBER}
    //     """
    // // export NEW_BRANCH=${branchName}-${BUILD_NUMBER}
    // //          echo $NEW_BRANCH
    //     // }
    //     }
    //   }
    // }
     
   }

}