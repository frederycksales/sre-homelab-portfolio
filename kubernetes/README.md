# Kubernetes & GitOps Management

This directory contains all Kubernetes manifests that define the desired state of our applications and services running on the cluster. This repository serves as the **Single Source of Truth** for our GitOps workflow.

The entire application lifecycle is managed by **Argo CD**. Manual `kubectl apply` commands against the cluster are discouraged and should only be used for initial bootstrapping or emergency troubleshooting.

## 1. Argo CD Bootstrap

Argo CD is the core of our GitOps engine. Its installation is the final manual step performed on the cluster.

### Installation

Argo CD was installed using the official stable manifests.

1.  **Create the namespace:**
    ```bash
    kubectl create namespace argocd
    ```

2.  **Apply the installation manifest:**
    ```bash
    kubectl apply -n argocd -f [https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml](https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml)
    ```

## 2. Accessing the Argo CD UI

To manage and visualize applications, you need to access the Argo CD web UI. The service is not exposed to the internet by default for security reasons. Access is achieved via `kubectl port-forward`.

### Workflow to Access the UI:

1.  **Start the Port Forward:**
    This command forwards your local port `8080` to the Argo CD server running inside the cluster. Open a dedicated terminal and run this command. It must remain running while you use the UI.
    ```bash
    kubectl port-forward svc/argocd-server -n argocd 8080:443
    ```

2.  **Get the Initial Admin Password:**
    Argo CD generates an initial password and stores it in a Kubernetes secret. Run this command to retrieve and decode it:
    ```bash
    kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
    ```

3.  **Log In:**
    * Open your web browser and navigate to: **`https://localhost:8080`**
    * You will see a browser warning about a self-signed certificate. It is safe to proceed.
    * The username is `admin`.
    * The password is the one you retrieved in the previous step.

## 3. Application Management

All applications deployed to this cluster are defined as Argo CD `Application` resources located in the `/apps` directory. The management workflow is as follows:

1.  Define a new application in a YAML file inside `/apps`.
2.  Commit and push the change to this Git repository.
3.  Argo CD will automatically detect the new file and deploy the application to the cluster.