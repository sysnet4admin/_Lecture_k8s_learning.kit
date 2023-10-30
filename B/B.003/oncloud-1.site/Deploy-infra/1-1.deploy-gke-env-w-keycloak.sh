# init info for keycloak app & infra 
export GCP_PROJECT=dbgong-team-20200512
export GCP_ZONE=us-central1-c
export KUBE_CLUSTER=hj-keycloak-oncloud-1-gke 
export CLUSTER_VERSION=1.27.5-gke.200

# static ingress IP. It will attach to Domain 
echo "Create Static external IP for Ingress"
gcloud compute addresses create hj-keycloak-oncloud-1-static-ip \
  --global \
  --ip-version IPV4
echo "---"

# enable container & containerregistry API
echo "Enable container & containerregistry API"
gcloud services enable container.googleapis.com containerregistry.googleapis.com
echo "---"

# Deploy GKE cluster for keycloak
echo "Create GKE cluster $CLUSTER_VERSION"
gcloud container clusters create $KUBE_CLUSTER \
--num-nodes=3 \
--zone=${GCP_ZONE} \
--no-enable-autorepair \
--no-enable-autoupgrade \
--location-policy=BALANCED \
--enable-identity-service \
--cluster-version="${CLUSTER_VERSION}" \
--release-channel=None \
--labels=keycloak=oncloud-1
echo "---"

# Get GKE auth 
echo "GKE get-credentials"
gcloud container clusters get-credentials ${KUBE_CLUSTER} --project ${GCP_PROJECT} --zone ${GCP_ZONE}
kubectx $KUBE_CLUSTER=.
echo "---"

# Deploy keycloak 
# notice: helm version should be 3.8.0 at least 
echo "Deploy keycloak to GKE"
echo "wait 120 seconds for stable GKE" ; sleep 120
helm install keycloak oci://registry-1.docker.io/bitnamicharts/keycloak \
--set auth.adminUser=admin \
--set auth.adminPassword=admin \
--set production=true \
--set proxy=edge \
--version 17.1.1

