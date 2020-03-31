function Apply-Config-Surely($title, $configCommand)
{
	$headLine = "==================================================================== " + $title + " ===================================================================="
	echo $headLine
	
	For ($i=1; $i -le 3; $i++) {
		$msg = "------------------------------(" + $i + ")--------------------------------------------(" + $i + ")"
		echo $msg
		Invoke-Expression $configCommand
    }
}

#secrets
echo "==================================================================== Managing Secrets ===================================================================="
kubectl delete secret laboschqpa-server-secrets
kubectl delete secret laboschqpa-filehost-secrets
kubectl create secret generic laboschqpa-server-secrets --from-file=secrets.properties=laboschqpa.k8s/setting_up_dev_env/server/secret/secrets-k8s_dev.properties
kubectl create secret generic laboschqpa-filehost-secrets --from-file=secrets.properties=laboschqpa.k8s/setting_up_dev_env/filehost/secret/secrets-k8s_dev.properties


#dev cluster resources
Apply-Config-Surely "Applying dev cluster specific config" "kubectl apply -f ${PWD}/laboschqpa.k8s/setting_up_dev_env"

#forcing Nginx to set up before Skaffold applies config of the particular microservices
Apply-Config-Surely "Applying Nginx config" "kubectl apply -f laboschqpa.k8s/dev/ingress-nginx"

#applying database config now, so it will be available when the microservices start up
Apply-Config-Surely "Applying DB config" "kubectl apply -f laboschqpa.k8s/dev/db"


#print the bearer token required for dashboard login
echo "==========================================================================================================================================================="
echo "===================================================================== DASHBOARD TOKEN ====================================================================="
kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | sls admin-user | ForEach-Object { $_ -Split '\s+' } | Select -First 1)
echo "==========================================================================================================================================================="


#starting Skaffold in "dev" mode
echo "================================================================= Starting Skaffold 'dev' ================================================================="
Start-Process "skaffold" "dev" -NoNewWindow -Wait -PassThru