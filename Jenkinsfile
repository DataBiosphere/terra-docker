
import hudson.model.*
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
      println("detected change for $currImage")
      filteredImages.add(currImage) 
    }
  }

  return filteredImages
}

//TODO: change to ~1
def Boolean hasImageChanged(dir) {
  def String output = sh (
        script: "git diff HEAD..HEAD~5 $dir",
        returnStdout: true
  ).trim()

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
  sh "echo 'building the following image: $imageDir'"
  def exitCode = sh(
    script: "$workingDir/build.sh $imageDir",
    returnStatus: true
  )

  if (exitCode != 0) {
    currentBuild.setResult(Result.UNSTABLE)
  }
}

def LinkedHashMap<String, String> getVersionMap(imageDirs) {
  def LinkedHashMap<String, String>  versionMap = [:]

  def currImageDir = ""
  for (int i = 0; i< imageDirs.size(); i++) {
    currImageDir = imageDirs[i]
    def workingDir = pwd()
    def version = sh(
      script: "cat $workingDir/$currImageDir/VERSION",
      returnStdout: true
    )
    versionMap["$currImageDir"] = "$version"
  }

  versionMap
}

pipeline {
   agent { label 'node210' }

//@@@@@@@@@@@ TODO: uncomment
  // options { 
      //we don't want to be building to PR changes at once, we will queue them instead
    // disableConcurrentBuilds() 
  // }

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


    //filter image directories based on whether there are changes, and then build all
    stage('Build Images') {
      steps {
        script {
          def ArrayList<String> changedImageDirs = getChangedImages()
          // buildAll(changedImageDirs)
          versionMap = getVersionMap(changedImageDirs)
            //have a corresponding text file or config with a map to the names in the leo confs to find and replace
          //then update the hash in the leo repo
        }
      }
    }

    stage('Leonardo Git') {
      steps {
        git credentialsId: 'jenkins-ssh-github', url: 'git@github.com:DataBiosphere/leonardo.git', branch: 'develop'
        sh "ls"
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