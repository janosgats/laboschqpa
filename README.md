# Labosch Qpa Web
Labosch Qpa Web is a microservice based simple architecture to serve web sites of 49th Qpa. 
This repository contains repositories of services in the architecture and is also used as the parent folder in local development. 

The contained repositories are:
1. Server (main webservice): https://github.com/janosgats/laboschqpa.server
2. FileHost (authed file up&download): https://github.com/janosgats/laboschqpa.filehost
3. ImageConverter (image transcoding job processor): https://github.com/janosgats/laboschqpa.imageconverter
4. Client (React + NextJS frontend): https://github.com/janosgats/laboschqpa.client
5. K8s (Kubernetes config files): https://github.com/janosgats/laboschqpa.k8s

<br>

CI/CD images on Docker Hub:

1. Server: https://hub.docker.com/repository/docker/gjani/laboschqpa-server/tags

   * [![Build Status](https://travis-ci.com/janosgats/laboschqpa.server.svg?branch=master)](https://travis-ci.com/github/janosgats/laboschqpa.server)

2. FileHost: https://hub.docker.com/repository/docker/gjani/laboschqpa-filehost/tags

   * [![Build Status](https://travis-ci.com/janosgats/laboschqpa.filehost.svg?branch=master)](https://travis-ci.com/github/janosgats/laboschqpa.filehost)

3. ImageConverter: https://hub.docker.com/repository/docker/gjani/laboschqpa-imageconverter/tags

   * [![Build Status](https://travis-ci.com/janosgats/laboschqpa.imageconverter.svg?branch=master)](https://travis-ci.com/github/janosgats/laboschqpa.imageconverter)

4. Client: https://hub.docker.com/repository/docker/gjani/laboschqpa-client/tags

   * [![Build Status](https://travis-ci.com/janosgats/laboschqpa.client.svg?branch=master)](https://travis-ci.com/github/janosgats/laboschqpa.client)
   
## Development

### Setting up the environment
* #### One-time steps
1. Clone this repo
2. Run `clone-downstream-repos.ps1` to clone the above repositories
3. Place the development secrets under `laboschqpa.k8s/setting_up_dev_env/<service_name>/secret/`
4. **!OPTIONAL!** *Do this Only if you want to use the **HostPath** PersistentVolume as storage **for FileHost**:* Open the `laboschqpa.k8s/setting_up_dev_env/nfs-server/nfs-server-pvc.yaml` and the `laboschqpa.k8s/setting_up_dev_env/pv/pv-volume-nfs-server.yaml` files and follow the instructions in them!  
5. Open `skaffold.yaml` and comment out the artifacts which you want to be pulled from DockerHub instead of be built locally on your computer!
6. Have *kubectl* installed
7. Have a (local) k8s cluster running and *kubectl* configured to use that cluster
8. Have [Skaffold](https://skaffold.dev/) installed
* #### Steps to repeat every time when you sit down to write some code 
9. Run `start-dev-env.ps1` to start your environment and see the logs streamed from the services
10. Skaffold will watch for filesystem changes and updates your cluster when something is changing.
      * **Java** services: You have to `gradle bootJar` build the code when you want an update since Dockerfiles are using the produced *.jar* file in local dev.
      * **JS** services: The cluster update triggers on changes in almost every file.


### Debugging
Open remote-debug ports for local development:
* Server: 30005 *(Java - JDK 9+)*
* FileHost: 30006 *(Java - JDK 9+)*
* ImageConverter: 30007 *(Java - JDK 9+)*
* Client: 30229 *(NodeJS - inspect)*

### Info
* Service hosting: GKE (Google Kubernetes Engine on GCP)
* SMTP: KSZK
* FileHost S3:
  * Provider: ScaleWay
  * bucket
    * dev: "laboschqpa-dev"
    * production: "laboschqpa"
* CI/CD: Jenkins
