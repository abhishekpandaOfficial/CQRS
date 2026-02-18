# GitOps With Argo CD (Planned CD)

This repository is now CI-ready for GitOps CD.

## What CI Already Produces

On `main` and release tags, Docker images are published with versioned tags:

- `latest` (main only)
- `<branch>`
- `sha-<commit>`
- `vX.Y.Z` / `X.Y.Z` / `X.Y`

These tags are suitable for Argo CD Image Updater policies.

## Recommended GitOps Layout

Use a separate GitOps repo (recommended):

- `gitops/environments/dev/...`
- `gitops/environments/stage/...`
- `gitops/environments/prod/...`

Each environment references fixed image tags or digests.

## Argo CD Image Updater Strategy

For each workload image:

- Allow semver tags (`1.x`, `1.2.x`, etc.) per environment policy.
- Ignore mutable tags for production promotion (`latest`).
- Prefer digest pinning after promotion.

## Example Application (Skeleton)

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cqrs-catalog
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/<org>/<gitops-repo>.git
    targetRevision: main
    path: environments/dev/cqrs-catalog
  destination:
    server: https://kubernetes.default.svc
    namespace: cqrs
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

## Example Image Updater Annotations (Skeleton)

```yaml
metadata:
  annotations:
    argocd-image-updater.argoproj.io/image-list: |
      write-api=docker.io/<dockerhub-user>/cqrs-catalog-write-api,
      read-api=docker.io/<dockerhub-user>/cqrs-catalog-read-api,
      projection-worker=docker.io/<dockerhub-user>/cqrs-catalog-projection-worker
    argocd-image-updater.argoproj.io/write-api.update-strategy: semver
    argocd-image-updater.argoproj.io/read-api.update-strategy: semver
    argocd-image-updater.argoproj.io/projection-worker.update-strategy: semver
```

## Promotion Model

1. Auto-update `dev` with semver policy.
2. Promote to `stage` by pull request in GitOps repo.
3. Promote to `prod` by pull request + approval.
4. Rollback by reverting GitOps commit.
