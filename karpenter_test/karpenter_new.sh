export KARPENTER_NAMESPACE="kube-system"
export KARPENTER_VERSION="0.37.0"
export K8S_VERSION="1.30"

export AWS_PARTITION="aws" # if you are not using standard partitions, you may need to configure to aws-cn / aws-us-gov
export CLUSTER_NAME="smriti-karpenter-new"
export AWS_DEFAULT_REGION="us-west-2"
export AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
export TEMPOUT="$(mktemp)"
export ARM_AMI_ID="$(aws ssm get-parameter --name /aws/service/eks/optimized-ami/${K8S_VERSION}/amazon-linux-2-arm64/recommended/image_id --query Parameter.Value --output text)"
export AMD_AMI_ID="$(aws ssm get-parameter --name /aws/service/eks/optimized-ami/${K8S_VERSION}/amazon-linux-2/recommended/image_id --query Parameter.Value --output text)"
export GPU_AMI_ID="$(aws ssm get-parameter --name /aws/service/eks/optimized-ami/${K8S_VERSION}/amazon-linux-2-gpu/recommended/image_id --query Parameter.Value --output text)"

echo "${KARPENTER_NAMESPACE}" "${KARPENTER_VERSION}" "${K8S_VERSION}" "${CLUSTER_NAME}" "${AWS_DEFAULT_REGION}" "${AWS_ACCOUNT_ID}" "${TEMPOUT}" "${ARM_AMI_ID}" "${AMD_AMI_ID}" "${GPU_AMI_ID}"

# curl -fsSL https://raw.githubusercontent.com/aws/karpenter-provider-aws/v"${KARPENTER_VERSION}"/website/content/en/preview/getting-started/getting-started-with-karpenter/cloudformation.yaml  > "${TEMPOUT}" \
# && aws cloudformation deploy \
#   --stack-name "Karpenter-${CLUSTER_NAME}" \
#   --template-file "${TEMPOUT}" \
#   --capabilities CAPABILITY_NAMED_IAM \
#   --parameter-overrides "ClusterName=${CLUSTER_NAME}"

# eksctl create cluster -f - <<EOF
# ---
# apiVersion: eksctl.io/v1alpha5
# kind: ClusterConfig
# metadata:
#   name: ${CLUSTER_NAME}
#   region: ${AWS_DEFAULT_REGION}
#   version: "${K8S_VERSION}"
#   tags:
#     karpenter.sh/discovery: ${CLUSTER_NAME}

# iam:
#   withOIDC: true
#   podIdentityAssociations:
#   - namespace: "${KARPENTER_NAMESPACE}"
#     serviceAccountName: karpenter
#     roleName: ${CLUSTER_NAME}-karpenter
#     permissionPolicyARNs:
#     - arn:${AWS_PARTITION}:iam::${AWS_ACCOUNT_ID}:policy/KarpenterControllerPolicy-${CLUSTER_NAME}

# iamIdentityMappings:
# - arn: "arn:${AWS_PARTITION}:iam::${AWS_ACCOUNT_ID}:role/KarpenterNodeRole-${CLUSTER_NAME}"
#   username: system:node:{{EC2PrivateDNSName}}
#   groups:
#   - system:bootstrappers
#   - system:nodes
#   ## If you intend to run Windows workloads, the kube-proxy group should be specified.
#   # For more information, see https://github.com/aws/karpenter/issues/5099.
#   # - eks:kube-proxy-windows

# managedNodeGroups:
# - instanceType: m5.large
#   amiFamily: AmazonLinux2
#   name: ${CLUSTER_NAME}-ng
#   desiredCapacity: 2
#   minSize: 1
#   maxSize: 10

# addons:
# - name: eks-pod-identity-agent
# EOF

export CLUSTER_ENDPOINT="$(aws eks describe-cluster --name "${CLUSTER_NAME}" --query "cluster.endpoint" --output text)"
export KARPENTER_IAM_ROLE_ARN="arn:${AWS_PARTITION}:iam::${AWS_ACCOUNT_ID}:role/${CLUSTER_NAME}-karpenter"

echo "${CLUSTER_ENDPOINT} ${KARPENTER_IAM_ROLE_ARN}"

# Logout of helm registry to perform an unauthenticated pull against the public ECR
helm registry logout public.ecr.aws

helm upgrade --install karpenter oci://public.ecr.aws/karpenter/karpenter --version "${KARPENTER_VERSION}" --namespace "${KARPENTER_NAMESPACE}" --create-namespace \
  --set "settings.clusterName=${CLUSTER_NAME}" \
  --set "settings.interruptionQueue=${CLUSTER_NAME}" \
  --set controller.resources.requests.cpu=1 \
  --set controller.resources.requests.memory=1Gi \
  --set controller.resources.limits.cpu=1 \
  --set controller.resources.limits.memory=1Gi \
  --wait
# Logout of helm registry to perform an unauthenticated pull against the public ECR
helm registry logout public.ecr.aws

helm upgrade --install karpenter oci://public.ecr.aws/karpenter/karpenter --version "${KARPENTER_VERSION}" --namespace "${KARPENTER_NAMESPACE}" --create-namespace \
  --set "settings.clusterName=${CLUSTER_NAME}" \
  --set "settings.interruptionQueue=${CLUSTER_NAME}" \
  --set controller.resources.requests.cpu=1 \
  --set controller.resources.requests.memory=1Gi \
  --set controller.resources.limits.cpu=1 \
  --set controller.resources.limits.memory=1Gi \
  --wait
