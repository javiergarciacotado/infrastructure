# Table of Contents

## Core GitOps Concepts
Getting Started with FluxCD
Intermediate Usage
GitOps Architectural Designs
Operational Control & Insights
Advanced Patterns and ArgoCD Parallels
Bonus: Infrastructure as Code Integration

## Core GitOps Concepts

### Understanding GitOps Philosophy
   
GitOps is an operational model that uses Git as the single source of truth for declarative infrastructure and application configuration. It leverages Git's version control capabilities to manage deployments and operations. 

#### Key Principles:

- Declarative: Everything is described declaratively.
- Versioned and Immutable: All changes are tracked in Git.
- Pulled Automatically: Changes are pulled and applied automatically.
- Continuously Reconciled: The desired state is continuously reconciled.

#### GitOps vs Traditional CI/CD

Traditional CI/CD (Push-based)
┌─────────┐    ┌─────────┐    ┌─────────────┐    ┌─────────────┐
│   Git   │───▶│   CI    │───▶│ Build/Test  │───▶│   Deploy    │
│ Commit  │    │Pipeline │    │   Pipeline  │    │ to Cluster  │
└─────────┘    └─────────┘    └─────────────┘    └─────────────┘

GitOps (Pull-based)
┌─────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Git   │◄───│ GitOps Agent│◄───│ Kubernetes  │◄───│  Observe &  │
│ Config  │    │ (FluxCD)    │    │  Cluster    │    │ Reconcile   │
└─────────┘    └─────────────┘    └─────────────┘    └─────────────┘

##### GitOps Workflow

1. **Define Desired State**: Write declarative manifests (YAML files) for your applications and infrastructure.
2. **Store in Git**: Commit these manifests to a Git repository.
3. **GitOps Agent**: A GitOps agent (like FluxCD) continuously monitors the Git repository for changes.
4. **Pull Changes**: When changes are detected, the agent pulls the latest manifests.
5. **Apply Changes**: The agent applies the changes to the Kubernetes cluster, ensuring the actual state matches the desired state.
6. **Continuous Reconciliation**: The agent continuously checks the cluster state and reconciles it with the desired state in Git.
7. **Observability**: Use tools to monitor and visualize the state of your applications and infrastructure.
8. **Rollback**: If an issue occurs, you can revert to a previous state by rolling back the Git commit.
9. **Collaboration**: Teams can collaborate on changes through pull requests, enabling code reviews and discussions before applying changes.
10. **Security**: Access to the cluster is controlled through Git permissions, reducing the risk of unauthorized changes.
11. **Auditability**: All changes are tracked in Git, providing a complete history of modifications.
12. **Compliance**: Ensure compliance by enforcing policies through GitOps tools.
13. **Automation**: Automate deployments, scaling and updates using GitOps tools.

#### Benefits of GitOps

- Enhanced Security: No direct cluster access needed
- Better Auditability: All changes tracked in Git
- Faster Recovery: Easy rollbacks using Git history
- Consistent Deployments: Same process across all environments
- Developer Experience: Familiar Git workflow

## Prerequisites and Setup

- [kind](https://kind.sigs.k8s.io/docs/user/quick-start/) for local Kubernetes clusters.
- [kubectl](https://kubernetes.io/docs/tasks/tools/) for interacting with Kubernetes clusters.

```bash 
# Install Flux CLI
curl -s https://fluxcd.io/install.sh | sudo bash

# Verify installation
flux --version

# Create cluster
cat <<EOF | kind create cluster --name flux-demo --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
    - |
      kind: InitConfiguration
      nodeRegistration:
      kubeletExtraArgs:
      node-labels: "ingress-ready=true"
      extraPortMappings:
    - containerPort: 80
      hostPort: 80
      protocol: TCP
    - containerPort: 443
      hostPort: 443
      protocol: TCP
      EOF

# list clusters
kind get clusters
```

### Bootstrapping FluxCD

The below command will:

- Create a repository (if it doesn't exist)
- Install Flux components in the cluster
- Configure Flux to sync from the repository
- Create initial directory structure

```bash
# Set environment variables
export GITHUB_TOKEN=<your-github-token>
export GITHUB_USER=<your-github-username>
export GITHUB_REPO=<your-repo-name>

# Bootstrap Flux
flux bootstrap github \
  --owner=$GITHUB_USER \
  --repository=$GITHUB_REPO \
  --branch=main \
  --path=./clusters/my-cluster \
  --personal
```

#### Verifying Flux Installation

```bash
# Check Flux installation
flux check

# Check Flux components
kubectl get pods -n flux-system
flux get all

# Verify GitRepository
flux get sources git

# Check logs if needed
kubectl logs -n flux-system -l app=source-controller
kubectl logs -n flux-system -l app=kustomize-controller
```

#### Understanding Flux Components

```yaml
# Example: flux-system namespace after bootstrap
apiVersion: v1
kind: Namespace
metadata:
  name: flux-system
---
# Source Controller - Manages Git repositories
apiVersion: apps/v1
kind: Deployment
metadata:
  name: source-controller
  namespace: flux-system
---
# Kustomize Controller - Applies Kustomize configurations
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kustomize-controller
  namespace: flux-system
---
# Helm Controller - Manages Helm releases
apiVersion: apps/v1
kind: Deployment
metadata:
  name: helm-controller
  namespace: flux-system
---
# Notification Controller - Handles events and notifications
apiVersion: apps/v1
kind: Deployment
metadata:
  name: notification-controller
  namespace: flux-system
```
