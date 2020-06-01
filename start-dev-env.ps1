function WriteHeadline($title)
{
    $headLine = "==================================================================== " + $title + " ===================================================================="
    Write-Host $headLine
}

function WriteSmallHeadline($title)
{
    $headLine = "-------------------------------------------------------- " + $title
    Write-Host $headLine
}


#Repeating 'apply'-s several times, in case some resources depend on other resources (e.g. namespaces created).
function Apply-Config-Surely($title, $configCommand)
{
    WriteHeadline $title

	For ($i=1; $i -le 3; $i++) {
		$msg = "------------------------------(" + $i + ")--------------------------------------------(" + $i + ")"
		Write-Host $msg
		Invoke-Expression $configCommand
    }
}

function Get-PSScriptRoot-Path-For-Kubernetes()
{
    $driveLetter = $PSScriptRoot.Substring(0,1).ToLower()
    $kubernetesPath = "/host_mnt/" + $driveLetter + "/" + $PSScriptRoot.Substring(3)
    return $kubernetesPath
}

function Create-PV-For-Node-Modules()
{
    WriteHeadline "Creating PV for node_modules"
    WriteSmallHeadline "Determining path of node_modules directory"

    $nodeModulesPath = Get-PSScriptRoot-Path-For-Kubernetes
    $nodeModulesPath = $nodeModulesPath + "/laboschqpa.frontend/node_modules"

    $msg = "nodeModulesPath: " + $nodeModulesPath
    Write-Host $msg

    $pvOriginalYaml = Get-Content -path laboschqpa.k8s/setting_up_dev_env/pv/pv-volume-frontend-nodemodules-for-dev.yaml -Raw
    $pvPathInsertedYaml = $pvOriginalYaml -replace 'DEV_ENV_FRONTEND_NODE_MODULES_FOLDER_HOST_PATH_PLACEHOLDER', $nodeModulesPath

    #EchoSmallHeadline "Deleting old nodemodules PV"
    #kubectl delete pv pv-volume-frontend-nodemodules-for-dev
    WriteSmallHeadline "Applying new nodemodules PV"
    echo $pvPathInsertedYaml | kubectl apply -f -
}

WriteHeadline "Loading nfsd kernel module (modprobe nfsd)"
kubectl exec -it -n kube-system $(kubectl get pods -n kube-system | grep kube-proxy | awk '{ print $1 }') modprobe nfsd

#secrets
WriteHeadline "Managing Secrets"
kubectl delete secret laboschqpa-server-secrets
kubectl delete secret laboschqpa-filehost-secrets
kubectl create secret generic laboschqpa-server-secrets --from-file=secrets.properties=laboschqpa.k8s/setting_up_dev_env/server/secret/secrets-k8s_dev.properties
kubectl create secret generic laboschqpa-filehost-secrets --from-file=secrets.properties=laboschqpa.k8s/setting_up_dev_env/filehost/secret/secrets-k8s_dev.properties

Apply-Config-Surely "Applying miscellaneous cluster specific config" "kubectl apply -f ${PWD}/laboschqpa.k8s/setting_up_dev_env"

#forcing Nginx to set up before Skaffold applies config of the particular microservices
Apply-Config-Surely "Applying Nginx config" "kubectl apply -f laboschqpa.k8s/dev/ingress-nginx"

Apply-Config-Surely "Applying Metrics config" "kubectl apply -f laboschqpa.k8s/dev/metrics"


#Create-PV-For-Node-Modules

WriteHeadline "Applying Persistent Volumes config"
kubectl apply -f laboschqpa.k8s/setting_up_dev_env/pv

WriteHeadline "Applying NFS Server config"
kubectl apply -f laboschqpa.k8s/setting_up_dev_env/nfs-server

WriteHeadline "Applying DB config"
kubectl apply -f laboschqpa.k8s/setting_up_dev_env/db

WriteHeadline "Applying dev resources (dev_res)"
kubectl apply -f laboschqpa.k8s/setting_up_dev_env/dev_res

WriteHeadline "Applying Persistent Volumes Claims"
kubectl apply -f laboschqpa.k8s/dev/pvc

WriteHeadline "Pulling master images from DockerHub"
docker pull gjani/laboschqpa-server:master
docker pull gjani/laboschqpa-filehost:master
docker pull gjani/laboschqpa-frontentd:master


#print the bearer token required for dashboard login
Write-Host "==========================================================================================================================================================="
Write-Host "===================================================================== DASHBOARD TOKEN ====================================================================="
kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | sls admin-user | ForEach-Object { $_ -Split '\s+' } | Select -First 1)
Write-Host "==========================================================================================================================================================="

try
{
    ##starting Skaffold
    WriteHeadline "Starting Skaffold 'dev'"
    Start-Process "skaffold" "dev" -NoNewWindow -Wait -PassThru
}
finally
{
    WriteHeadline "Running 'skaffold delete' explicitly"
    Start-Process "skaffold" "delete" -NoNewWindow -Wait -PassThru
}