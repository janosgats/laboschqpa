function EchoHeadline($title)
{
    $headLine = "==================================================================== " + $title + " ===================================================================="
    echo $headLine
}

function EchoSmallHeadline($title)
{
    $headLine = "-------------------------------------------------------- " + $title
    echo $headLine
}


#Repeating 'apply'-s several times, in case some resources depend on other resources (e.g. namespaces created).
function Apply-Config-Surely($title, $configCommand)
{
    EchoHeadline $title

	For ($i=1; $i -le 3; $i++) {
		$msg = "------------------------------(" + $i + ")--------------------------------------------(" + $i + ")"
		echo $msg
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
    EchoHeadline "Creating PV for node_modules"
    EchoSmallHeadline "Determining path of node_modules directory"

    $nodeModulesPath = Get-PSScriptRoot-Path-For-Kubernetes
    $nodeModulesPath = $nodeModulesPath + "/laboschqpa.frontend/node_modules"

    $msg = "nodeModulesPath: " + $nodeModulesPath
    echo $msg

    $pvOriginalYaml = Get-Content -path laboschqpa.k8s/setting_up_dev_env/pv/pv-volume-frontend-nodemodules-for-dev.yaml -Raw
    $pvPathInsertedYaml = $pvOriginalYaml -replace 'DEV_ENV_FRONTEND_NODE_MODULES_FOLDER_HOST_PATH_PLACEHOLDER', $nodeModulesPath

    #EchoSmallHeadline "Deleting old nodemodules PV"
    #kubectl delete pv pv-volume-frontend-nodemodules-for-dev
    EchoSmallHeadline "Applying new nodemodules PV"
    echo $pvPathInsertedYaml | kubectl apply -f -
}

EchoHeadline "Loading nfsd kernel module (modprobe nfsd)"
kubectl exec -it -n kube-system $(kubectl get pods -n kube-system | grep kube-proxy | awk '{ print $1 }') modprobe nfsd

#secrets
EchoHeadline "Managing Secrets"
kubectl delete secret laboschqpa-server-secrets
kubectl delete secret laboschqpa-filehost-secrets
kubectl create secret generic laboschqpa-server-secrets --from-file=secrets.properties=laboschqpa.k8s/setting_up_dev_env/server/secret/secrets-k8s_dev.properties
kubectl create secret generic laboschqpa-filehost-secrets --from-file=secrets.properties=laboschqpa.k8s/setting_up_dev_env/filehost/secret/secrets-k8s_dev.properties

Apply-Config-Surely "Applying miscellaneous cluster specific config" "kubectl apply -f ${PWD}/laboschqpa.k8s/setting_up_dev_env"

#forcing Nginx to set up before Skaffold applies config of the particular microservices
Apply-Config-Surely "Applying Nginx config" "kubectl apply -f laboschqpa.k8s/dev/ingress-nginx"


#Create-PV-For-Node-Modules

EchoHeadline "Applying Persistent Volumes config"
kubectl apply -f laboschqpa.k8s/setting_up_dev_env/pv

EchoHeadline "Applying NFS Server config"
kubectl apply -f laboschqpa.k8s/setting_up_dev_env/nfs-server

EchoHeadline "Applying DB config"
kubectl apply -f laboschqpa.k8s/setting_up_dev_env/db

EchoHeadline "Applying dev resources (dev_res)"
kubectl apply -f laboschqpa.k8s/setting_up_dev_env/dev_res


#print the bearer token required for dashboard login
echo "==========================================================================================================================================================="
echo "===================================================================== DASHBOARD TOKEN ====================================================================="
kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | sls admin-user | ForEach-Object { $_ -Split '\s+' } | Select -First 1)
echo "==========================================================================================================================================================="


#starting Skaffold
EchoHeadline "Starting Skaffold 'dev'"
Start-Process "skaffold" "dev --cleanup=false" -NoNewWindow -Wait -PassThru