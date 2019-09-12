import hudson.model.*
import hudson.FilePath
import jenkins.model.Jenkins
def branchName = "automated-leonardo-hash-update-"

//declared in outer scope so it persists between steps
//omitting the 'def' is what makes it global
LinkedHashMap<String, String> versionMap = [:]

def ArrayList<String> getChangedImages() {
  def String[] images = readFile("imageDirs.txt").trim().split("\n")

  def filteredImages = []
  //we must use a c-style loop due to jenkins serialization, aka https://www.devopscat.tech/2018/10/what-is-noncps-in-jenkins-pipeline/
  for (String currImage in images) {
    if (hasImageChanged(currImage)) {
      println("detected change for $currImage")
      filteredImages.add(currImage) 
    }
  }

  return filteredImages
}

def Boolean hasImageChanged(dir) {
  def String output = sh (
        script: "git diff HEAD..HEAD~1 $dir",
        returnStdout: true
  ).trim()

  !output.isEmpty()
}

def void buildAll(ArrayList<String> imageDirs) {
  for (String imageDir in imageDirs) {
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

  //if we cannot build an image because it will cause an overwrite of the remote gcr image, we set the build to unstable. 
  //We do this because the most likely scenario is it was desired that the image to build, but the VERSION file was not updated.
  //we do not want to fail in this circumstance, as there are other images to build
  if (exitCode == 14) {
    println("The build script reported that building would result in overwritting an existing image. Setting build status to UNSTABLE. Consider updating the VERSION file for $imageDir")
    currentBuild.setResult("UNSTABLE")
    prevDesc = currentBuild.getDescription() == null ? "" : currentBuild.getDescription() + "\n"
    currentBuild.setDescription(prevDesc + "The build for image $imageDir failed because the image already exists.")
  } else if (exitCode != 0) {
    throw new RuntimeException("Unexpected error code recieved from build.sh: $exitCode")
  }
}

def LinkedHashMap<String, String> getVersionMap(imageDirs) {
  def LinkedHashMap<String, String>  versionMap = [:]

  for (String currImageDir in imageDirs) {
    def workingDir = pwd()
    def version = sh(
      script: "cat $workingDir/$currImageDir/VERSION",
      returnStdout: true
    ).trim()
    versionMap[currImageDir] = version
  }

  versionMap
}

//versionMap must be defined by a previous step for this to work
def void updateConfigHashes(replacementMap) {
  def String[] configPaths = readFile("jenkins/confLocations.txt").trim().split("\n")
  for (String currConfig in configPaths) {
    println("Calling replaceTag function for $currConfig with $replacementMap")
    replaceTags(currConfig, replacementMap)

    println("printing changes in $currConfig and running git add")
    sh(
      script: "git diff $currConfig; git add $currConfig"
    )
  }
}

//parameterize with ":" prefix and end quote suffix instead of hardcode?
def void replaceTags(String filePath, LinkedHashMap<String, String> replacementMap) {
  def contents = readFile(filePath).split('\n')

  println("contents of $filePath before modification is $contents")

  def currLine = ""
  for (String currReplacement in replacementMap.keySet()) {
    for (int j = 0; j < contents.size(); j++) {
      currLine = contents[j]
      if (currLine.contains(currReplacement))  {
        location = currLine.indexOf(currReplacement)
        //we add 1 because the image name is suffixed with : before the tag we wish to replace
        def String newLine = currLine.substring(0, location + currReplacement.length() + 1) + replacementMap[currReplacement] + '"'
        println("replacing line $currLine with $newLine")
        contents[j] = newLine
      }
    }
  }

  println("contents of $filePath after modification is $contents")
  def joinedContents = contents.join('\n')
  def workingDir = pwd()
 
  fp = createFilePath("$workingDir/$filePath")
  //we add the trailing newline as its lost in the split/join process
  fp.write(joinedContents + "\n", "UTF-8")
}

//Filepath is an object that abstracts away the fact the file can be on a remote node or the master node
def FilePath createFilePath(String path) {
    if (env['NODE_NAME'] == null) {
        throw new RuntimeException("envvar NODE_NAME is not set, probably not inside a node {} or running a different version of Jenkins!");
    } else if (env['NODE_NAME'].equals("master")) {
        return new FilePath(path);
    } else {
        println("detecting remote file in createFilePath")
        return new FilePath(Jenkins.getInstance().getComputer(env['NODE_NAME']).getChannel(), path);
    }
}

pipeline {
   agent { label 'node210' }

  options { 
    //we don't want to be building to PR changes at once, we will queue them instead
    disableConcurrentBuilds() 
  }

   stages {
     
    stage('Terra Docker Git') {
      steps {
        git credentialsId: 'jenkins-ssh-github', url: 'git@github.com:DataBiosphere/terra-docker.git', branch: 'jc-jenkinsfile'
      }
    }

    stage('Docker Auth') {
      steps {
        //the chown is necessary because something on the jenkins instance keeps touching the logs with sudo and changing the owner to root
        //this which causes gcloud auth command to fail
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

          // if (changedImageDirs.isEmpty()) {
          //       currentBuild.setResult('ABORTED')
          //       currentBuild.get
          // }

        //TODO, check if there are any changes, and abort appropriately if none

          buildAll(changedImageDirs)
          //@@@@@@@@@@@@TODO: remove this
          // sh "echo '0.0.2' > terra-jupyter-python/VERSION"
          versionMap = getVersionMap(changedImageDirs)
        }
      }
    }

    stage('Leonardo Git') {
      steps {
        git credentialsId: 'jenkins-ssh-github', url: 'git@github.com:DataBiosphere/leonardo.git', branch: 'jc-jenkinsfile'
      }
    }

    //update the built image hashes in the leo repo
    stage('Update Leonardo Hashes') {
      steps {
        sh """
          git submodule init && git submodule update
        """

        script {
          updateConfigHashes(versionMap)
        }

        sshagent(['jenkins-ssh-github']) {
          sh """
            git checkout -b $branchName${BUILD_NUMBER}
            git commit -m "automated config hash updates"
            git push origin $branchName${BUILD_NUMBER}
          """
        }
      }
    }

    stage('Notify Slack') {
      steps {
        
        slackSend(channel: '#newrelictest', message: "Jenkins has successfully created a branch with the updated terra-docker hashes.\n" +
         "https://github.com/DataBiosphere/leonardo/compare/develop...$branchName${BUILD_NUMBER}")
        //  slackNotifier {
        //     notifyFailure(true)
        //     notifyRepeatedFailure(true)
        //     notifySuccess(true)
        //     // includeCustomMessage(true)
        //     // customMessage("Jenkins has successfully created a branch with the updated welder hash.\n" +
        //             // "https://github.com/DataBiosphere/leonardo/compare/develop...${branchBaseName}\${BUILD_NUMBER}")
        //     room("newrelictest")
        // }
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