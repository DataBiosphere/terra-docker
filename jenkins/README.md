There is a jenkins job titled leonardo-build-terra-docker that is sourced off the Jenkinsfile in this repository.
It is used to detect a change in any of the folders listed in imageDirs.txt, build the image with build.sh, and update the relevant hashes in the leonardo repo. 
Only images following the names specified in imageDirs.txt will be updated in leonardo.


There is a file in the leonardo repo's jenkins folder called 'confLocations.txt' which is also relied on by this job, which specifies the files that require updating.
