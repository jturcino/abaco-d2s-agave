# abaco-d2s-agave
A [Docker container](https://hub.docker.com/r/jturcino/abaco-d2s-agave/) for registering a [docker2singularity](https://github.com/TACC/docker2singularity) actor with [Abaco](https://github.com/TACC/abaco) that stores the produced [Singularity](http://singularity.lbl.gov/) images on a specified [Agave](https://agaveapi.co/) filesystem.

**If you do not have access to an Agave storage system, but you do have access to Docker, please use the [abaco-d2s-generic](https://github.com/jturcino/abaco-d2s-generic) repo instead.**

## Overview

The contents of this repo describe the `abaco-d2s-agave` Docker container that can be registered as an Abaco actor. When run as such an actor, the container will transform another, user-provided Docker container to a Singularity image before storing the image on the provided Agave storage system. The actor requires three inputs: 
* **the Docker container** to transform to a Singularity image
* **the storage system** on which to save the Singularity image
* **the file path** at which to save the Singularity image

You will need the [Abaco CLI](https://github.com/johnfonner/abaco-cli) to interface with Abaco and walk through the tutorial below.

## Tutorial
In this tutorial, we will register the `abaco-d2s-generic` Docker container as an Agave actor and submit a sample job using said actor. The Abaco CLI commands for each step are below. Please note that a SD2E access token, JQ, getopts, and the [Agave CLI](https://bitbucket.org/agaveapi/cli) are required.

### 1. Obtain some info we'll need in the future
Use the Agave CLI to obtain a valid SD2E access token and to determine which system and filepath you will be using. Be sure to save the system and filepath to variables for later use.
```
$ auth-tokens-create -S
$ systems-list -S
my-personal-storage    general-storage
$ system="my-personal-storage"
$ files-list -S $system /projects/abaco/d2s/
.
$ outdir="/projects/abaco/d2s"
```

### 2. Create the actor
Move into a directory that has access to the Abaco CLI. Use `abaco create` to create a privileged actor, adding the `outdir` and `system` as environmental variables. Once run, make note of the actor ID (`ZVO8GLWGzPgbK`)
```
$ ./abaco create -p -u -e "{\"system\": \"$system\", \"outdir\": \"$outdir\"}" \
  -n d2s-agave-tutorial jturcino/abaco-d2s-agave:latest
d2s-agave-tutorial    ZVO8GLWGzPgbK
```

### 3. Check the actor's status
Use `abaco list` to check if the actor has `READY` status. If the status is stil `SUBMITTED`, wait a few moments before checking again.
```
$ ./abaco list
d2s-agave-tutorial    ZVO8GLWGzPgbK    READY
```

### 4. Submit the job
Use `abaco submit` to run the actor once its status is `READY`. Be sure to provide the Docker container you wish to transform with the `-m` flag. Here, we are using the `docker/whalesay` sample container. Once, run, make note of the execution ID (`mwzXallP3GqvG`).
```
$ ./abaco submit -m 'docker/whalesay:latest' ZVO8GLWGzPgbK
mwzXallP3GqvG
'docker/whalesay:latest'
```

### 5. Check the job's status
Use `abaco executions` to see if the job has finished. Be sure to provide both the actor ID (`ZVO8GLWGzPgbK`) and the execution ID (`mwzXallP3GqvG`).
```
$ ./abaco executions -e mwzXallP3GqvG ZVO8GLWGzPgbK
WxLQyawqywwAW    COMPLETE
```

### 6. Check the job's logs
Use `abaco logs` to check that the job ran properly by providing the actor ID and execution ID. The example logfile below has been cleaned up for clarity.
```
$ ./abaco logs -e mwzXallP3GqvG ZVO8GLWGzPgbK
Logs for execution mwzXallP3GqvG:
Unable to find image 'docker/whalesay:latest' locally
latest: Pulling from docker/whalesay
...
Status: Downloaded newer image for docker/whalesay:latest
Size: 419 MB for the singularity container
(1/9) Creating an empty image...
(2/9) Importing filesystem...
(3/9) Bootstrapping...
(4/9) Adding run script...
(5/9) Setting ENV variables...
(6/9) Adding mount points...
(7/9) Fixing permissions...
(8/9) Stopping and removing the container...
(9/9) Moving the image to the output folder...

CLEANING UP

PROCESS COMPLETED
    Container: docker/whalesay:latest
    System: data-tacc-work-jturcino
    Outdir: /projects/docker/abaco-biocontainers/
    Image: whalesay_latest.img
```

### 7. View the image
Use the Agave CLI again to view the files stored on `$system` at `$outdir`. The image file (given at the bottom of the log file) should be there!
```
$ files-list -S $system $outdir
.
whalesay_latest.img
```
You can now use the Agave `files-get` command to download the image file to your local machine, or do anything else that you'd like with it!