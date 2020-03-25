#secrets
kubectl delete secret laboschcst-server-secrets
kubectl delete secret laboschcst-filehost-secrets
kubectl create secret generic laboschcst-server-secrets --from-file=secrets.properties=laboschcst.k8s/setting_up_dev_env/server/secret/secrets-k8s_dev.properties
kubectl create secret generic laboschcst-filehost-secrets --from-file=secrets.properties=laboschcst.k8s/setting_up_dev_env/filehost/secret/secrets-k8s_dev.properties

#dev cluster resources
kubectl apply -f laboschcst.k8s/setting_up_dev_env

#forcing Nginx to set up before Skaffold applies config of the particular microservices
kubectl apply -f laboschcst.k8s/dev/ingress-nginx
kubectl apply -f laboschcst.k8s/dev/ingress-nginx
kubectl apply -f laboschcst.k8s/dev/ingress-nginx

#starting Skaffold in "dev" mode
skaffold dev
