#secrets
kubectl delete secret laboschqpa-server-secrets
kubectl delete secret laboschqpa-filehost-secrets
kubectl create secret generic laboschqpa-server-secrets --from-file=secrets.properties=laboschqpa.k8s/setting_up_dev_env/server/secret/secrets-k8s_dev.properties
kubectl create secret generic laboschqpa-filehost-secrets --from-file=secrets.properties=laboschqpa.k8s/setting_up_dev_env/filehost/secret/secrets-k8s_dev.properties

#dev cluster resources
kubectl apply -f laboschqpa.k8s/setting_up_dev_env

#forcing Nginx to set up before Skaffold applies config of the particular microservices
kubectl apply -f laboschqpa.k8s/dev/ingress-nginx
kubectl apply -f laboschqpa.k8s/dev/ingress-nginx
kubectl apply -f laboschqpa.k8s/dev/ingress-nginx

#starting Skaffold in "dev" mode
skaffold dev
