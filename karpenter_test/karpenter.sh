export AWS_PARTITION="aws" # if you are not using standard partitions, you may need to configure to aws-cn / aws-us-gov
export CLUSTER_NAME="smriti-karpenter-test"
export AWS_REGION="us-west-2"
export OIDC_ENDPOINT="$(aws eks describe-cluster --name ${CLUSTER_NAME} --query "cluster.identity.oidc.issuer" --output text)"
export AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"

export KARPENTER_VERSION="0.37.0"
export KARPENTER_NAMESPACE=karpenter

echo "cluster name: ${CLUSTER_NAME}", aws region: "${AWS_REGION}", account id: "${AWS_ACCOUNT_ID}", oidc endpoint: "${OIDC_ENDPOINT}"

export K8S_VERSION=1.28
export ARM_AMI_ID="ami-06378a82bdb4de802"
export AMD_AMI_ID="ami-0408823a87d4095d9"
export GPU_AMI_ID="ami-07dd1b9e1928d9121"
# ARM_AMI_ID="$(aws ssm get-parameter --name /aws/service/eks/optimized-ami/${K8S_VERSION}/amazon-linux-2-arm64/recommended/image_id --query Parameter.Value --output text)"
# AMD_AMI_ID="$(aws ssm get-parameter --name /aws/service/eks/optimized-ami/${K8S_VERSION}/amazon-linux-2/recommended/image_id --query Parameter.Value --output text)"
# GPU_AMI_ID="$(aws ssm get-parameter --name /aws/service/eks/optimized-ami/${K8S_VERSION}/amazon-linux-2-gpu/recommended/image_id --query Parameter.Value --output text)"

# echo "arm ami id: ${ARM_AMI_ID}, amd ami id: ${AMD_AMI_ID}, gpu ami id: ${GPU_AMI_ID}"

# aws iam create-role --role-name "KarpenterNodeRole-${CLUSTER_NAME}" \
#     --assume-role-policy-document file://node-trust-policy.json

# aws iam attach-role-policy --role-name "KarpenterNodeRole-${CLUSTER_NAME}" \
#     --policy-arn "arn:${AWS_PARTITION}:iam::aws:policy/AmazonEKSWorkerNodePolicy"

# aws iam attach-role-policy --role-name "KarpenterNodeRole-${CLUSTER_NAME}" \
#     --policy-arn "arn:${AWS_PARTITION}:iam::aws:policy/AmazonEKS_CNI_Policy"

# aws iam attach-role-policy --role-name "KarpenterNodeRole-${CLUSTER_NAME}" \
#     --policy-arn "arn:${AWS_PARTITION}:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"

# aws iam attach-role-policy --role-name "KarpenterNodeRole-${CLUSTER_NAME}" \
#     --policy-arn "arn:${AWS_PARTITION}:iam::aws:policy/AmazonSSMManagedInstanceCore"


# aws iam create-role --role-name "KarpenterControllerRole-${CLUSTER_NAME}" \
#     --assume-role-policy-document file://controller-trust-policy.json

# aws iam attach-role-policy --role-name "KarpenterControllerRole-${CLUSTER_NAME}" \ 
#     --policy-name "KarpenterControllerPolicy-${CLUSTER_NAME}" \
#     --policy-document file://controller-policy.json

helm template karpenter oci://public.ecr.aws/karpenter/karpenter --version "${KARPENTER_VERSION}" --namespace "${KARPENTER_NAMESPACE}" \
    --set "settings.clusterName=${CLUSTER_NAME}" \
    --set "serviceAccount.annotations.eks\.amazonaws\.com/role-arn=arn:${AWS_PARTITION}:iam::${AWS_ACCOUNT_ID}:role/KarpenterControllerRole-${CLUSTER_NAME}" \
    --set controller.resources.requests.cpu=1 \
    --set controller.resources.requests.memory=1Gi \
    --set controller.resources.limits.cpu=1 \
    --set controller.resources.limits.memory=1Gi > karpenter.yaml
