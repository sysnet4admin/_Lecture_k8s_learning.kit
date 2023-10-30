#!/usr/bin/env bash

# declare variable.
DOMAIN_NAME=oncloud-2
CLIENT_SECRET=Ay640idvu4XFZSkWYFmLsLk3NdzuOfDI

#  keycloak-login-config 
rm -rf ~/.keycloak ; mkdir ~/.keycloak
kubectl get clientconfig --context=hj-keycloak-${DOMAIN_NAME}-gke -n kube-public default -o yaml > ~/.keycloak/config

rm -rf /usr/local/bin/kubelogin 
cat > "/usr/local/bin/kubelogin.tmp" <<'EOF'
#!/usr/bin/env bash

function kubelogin() {
    local vendor="$(cat ~/.kube/config | grep current-context | cut -d ':' -f2 | grep gke)"

    if [ "$vendor" != "" ]; then
        kubectl oidc login --cluster="hj-keycloak-${DOMAIN_NAME}-gke" --login-config="/Users/mz01-hj/.keycloak/config"
    else
        kubectl oidc-login get-token \
          --oidc-issuer-url=https://${DOMAIN_NAME}.site/realms/kubernetes \
          --oidc-client-id=k8s-auth \
          --oidc-client-secret=${CLIENT_SECRET}
    fi
}

kubelogin
EOF

vendor='$vendor' DOMAIN_NAME=$DOMAIN_NAME CLIENT_SECRET=$CLIENT_SECRET envsubst < /usr/local/bin/kubelogin.tmp >> /usr/local/bin/kubelogin
rm /usr/local/bin/kubelogin.tmp
sudo chmod 755 "/usr/local/bin/kubelogin"
echo "kubelogin installed successfully"

