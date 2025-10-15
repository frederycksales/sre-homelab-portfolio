# Kubernetes & GitOps Bootstrap

This directory contains the Kubernetes manifests required to bootstrap the GitOps engine for the cluster.

The core philosophy of this project is that all application and service deployments are managed via GitOps. Therefore, the only manifests applied manually from this repository are those needed to connect the cluster to its source of truth.

## 1. Argo CD Installation

Argo CD is the core of our GitOps engine. The process for its installation is documented here for reproducibility.

**Create the namespace:**

```bash
kubectl create namespace argocd
```

**Apply the installation manifest:**

```bash
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

## 2. The "App of Apps" Bootstrap (root-app.yml)

The `root-app.yml` manifest is the single, crucial link between this platform and its application definitions.

**Purpose:** This is an Argo CD Application resource that instructs Argo CD to monitor the `sre-homelab-apps` repository.

**Workflow:** It is applied manually once after Argo CD is installed.

```bash
kubectl apply -f kubernetes/root-app.yml
```

**Result:** This bootstrap step effectively hands over control of all future deployments to the `sre-homelab-apps` repository.

## 3. Accessing the Argo CD UI

To manage and visualize the GitOps workflow, you need to access the Argo CD web UI. Access is achieved securely via `kubectl port-forward`.

**Workflow to Access the UI:**

1. **Start the Port Forward:** This command forwards your local port 8080 to the Argo CD server. Open a dedicated terminal and keep this command running.

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

2. **Get the Initial Admin Password:** Argo CD generates an initial password and stores it in a Kubernetes secret. Run this command to retrieve and decode it:

```bash
kubectl get secret argocd-initial-admin-secret \
  -n argocd \
  -o jsonpath="{.data.password}" | base64 -d
```

3. **Log In:**
   * Open your web browser and navigate to: **`https://localhost:8080`**
   * Proceed past the browser's security warning (this is safe as the certificate is self-signed).
   * Username: `admin`
   * Password: The password retrieved in the previous step.

## 4. Application Management

**IMPORTANT:** No application manifests are stored in this repository.

All applications deployed to the cluster are defined in a dedicated Git repository: **`sre-homelab-apps`**

The day-to-day workflow is to commit new application manifests to that repository. Argo CD will then automatically deploy them.