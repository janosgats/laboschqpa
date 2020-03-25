# Labosch CST Web
Labosch CST Web is a microservice based simple architecture to serve web sites of 50th CST. 
This repository contains repositories of services in the architecture and is also used as the parent folder in local development. 

The contained repositories are:
1. Server (main webservice): https://github.com/janosgats/laboschcst.server
2. FileHost (large-file up/download): https://github.com/janosgats/laboschcst.filehost
3. Frontend (React client): https://github.com/janosgats/laboschcst.frontend
4. K8s (Kubernetes config files): https://github.com/janosgats/laboschcst.k8s

## Development

### Setting up the environment
* #### One-time steps
1. Clone this repo
2. Run `clone-downstream-repos.ps1` to clone the above repositories
3. Place development secrets under `laboschcst.k8s/setting_up_dev_env/<service_name>/secret/`
4. Edit *.yaml* files in `laboschcst.k8s/setting_up_dev_env/` to provide PC specific resources for your local k8s cluster (currently, this means setting the `size` and `hostPath` of `pv-volume-filehost-storedfiles.yaml`)
5. Have a (local) k8s cluster running and *kubectl* configured to use that cluster
6. Have [Skaffold](https://skaffold.dev/) installed
* #### Steps to repeat every time when you sit down to write some code 
7. Run `start-dev-env.ps1` to start your environment and see the logs streamed from the services
8. Skaffold will watch for filesystem changes and updates your cluster when something is changing.
      * **Java** services: You have to `mvn package` build the code when you want an update since Dockerfiles are using the produced *.jar* file in local dev.
      * **JS** services: The cluster update triggers on changes in almost every file.


### Debugging
Opened remote-debug ports for local development:
* Server: 30005 *(Java - JDK 9+)*
* FileHost: 30006 *(Java - JDK 9+)*