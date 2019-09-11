def branchName = "delete-me"

//declared in outer scope so it persists between steps
def LinkedHashMap<String, String> versionMap = [:]

def ArrayList<String> getChangedImages() {
  def String[] images = readFile("imageDirs.txt").trim().split("\n")

  def filteredImages = []
  //we must use a c-style loop due to jenkins serialization, aka https://www.devopscat.tech/2018/10/what-is-noncps-in-jenkins-pipeline/
  def currImage = ""
  for (int i = 0; i < images.size(); i++) {
    currImage = images[i]
    if(hasImageChanged(currImage)) {
      filteredImages.add(currImage) 
    }
  }

  return filteredImages
}

def Boolean hasImageChanged(dir) {
  def String output = sh (
        script: "git diff HEAD..HEAD~5 $dir",
        returnStdout: true
  ).trim()

  println("output for $dir is $output")

  !output.isEmpty()
}

def void buildAll(ArrayList<String> imageDirs) {
  def imageDir = ""
  for (int i = 0; i < imageDirs.size(); i++) {
    imageDir = imageDirs[i]
    buildImage(imageDir)
  }
}

def void buildImage(String imageDir) {
  def workingDir = pwd()
  sh "echo 'printing in buildImage function: $imageDir'"
  sh "$workingDir/build.sh $imageDir"
}

def LinkedHashMap<String, String> getVersionMap(imageDirs) {
  def LinkedHashMap<String, String>  versionMap = [:]

  def currImageDir = ""
  for (int i = 0; i< imageDirs.size(); i++) {
    currImageDir = imageDirs[i]
    def workingDir = pwd()
    def version = sh(
      script: "cat $workingDir/$currImageDir/VERSION"
      returnStdout: true
    )
    versionMap["$imageDir"] = "$version"
  }

  versionMap
}

pipeline {
   agent { label 'node210' }

   stages {
     
    stage('Terra Docker Git') {
      steps {
        git credentialsId: 'jenkins-ssh-github', url: 'git@github.com:DataBiosphere/terra-docker.git', branch: 'jc-jenkinsfile'
      }
    }

    stage('Docker Auth') {
      steps {
        //# the chown is necessary because something on the jenkins instance keeps touching the logs with sudo and changing the owner to root, which causes gcloud auth command to fail
        sh """
          sudo chown -R jenkins:jenkins /home/jenkins/.config
          docker run --rm  -v /etc/vault-token-dsde:/root/.vault-token:ro broadinstitute/dsde-toolbox:latest vault read --format=json secret/dsde/dsp-techops/common/dspci-wb-gcr-service-account.json | jq .data > dspci-wb-gcr-service-account.json   
          gcloud auth activate-service-account --key-file=dspci-wb-gcr-service-account.json
          gcloud auth configure-docker --quiet
        """
      }
    }

    stage('Build Images') {
      steps {

        //filter image directories based on whether there are changes, and then build all
        script {
          def ArrayList<String> changedImageDirs = getChangedImages()
          buildAll(changedImageDirs)
          versionMap = getVersionMap(changedImageDirs)
          println versionMap
            //have a corresponding text file or config with a map to the names in the leo confs to find and replace
          //then update the hash in the leo repo
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