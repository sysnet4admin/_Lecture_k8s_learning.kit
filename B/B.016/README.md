# Your First Gateway API Migration in 5 Minutes — Live Demo

> KubeCon Japan 2026 · Repro materials for the "I Tested 7 So You Only Need 1" live demo.
> **working → broken → recovered**: delete the Ingress, convert it with `ingress2gateway`,
> and recover onto Gateway API on the same IP. You can follow the whole flow yourself.

## What it shows

1. Continuous **curl** against an endpoint served by ingress-nginx (working)
2. Delete the Ingress → curl **fails** (broken) — the "ingress-nginx retirement" situation
3. Convert the Ingress to Gateway API (Gateway + HTTPRoute) with **ingress2gateway**
4. Deploy on the **same IP** with **NGINX Gateway Fabric**
5. curl **recovers** with no URL change (recovered)

The heart of the tooling is a single **ingress2gateway** command. Everything else (same IP, near-zero downtime) exists to prove "is it really that easy".

## Prerequisites

| Item | Value |
|---|---|
| Cluster | Kubernetes (LoadBalancer capable, e.g. MetalLB) |
| GatewayClass | `nginx` (NGINX Gateway Fabric) installed and Accepted |
| Tools | `ingress2gateway` 1.1.0 (`brew install ingress2gateway`), `helm`, `kubectl` |
| Gateway API | v1.x CRDs installed |

> On a fresh cluster (e.g. you only ran `vagrant up` instead of `cluster/up.sh`), both the cluster
> infra layers may be absent — **MetalLB** (LB IP pool) and the **GatewayClass + Gateway API CRDs**.
> You do **not** have to install them by hand: `0.setup_before.sh` detects each and runs
> `cluster/metallb.sh` / `cluster/install-ngf.sh` for you once, then skips them on every later run.

> Why NGF: across seven implementations we measured, the **smoothest first path coming from
> ingress-nginx** was NGF, the same NGINX engine. For the full comparison see the companion
> session "The Gateway Readiness Score" and
> https://github.com/sysnet4admin/Research/tree/main/gateway-PoC.

## Run

```bash
# 0) Pick the demo IP (a free address in the cluster LB pool)
export DEMO_IP=192.168.1.12

# 1) Build BEFORE: ingress-nginx + jp-front + Ingress, AND pre-warm the NGF Gateway
./scripts/0.setup_before.sh

# 2) Left pane: continuous curl (keep it running for the whole demo)
DEMO_IP=$DEMO_IP ./scripts/watch_curl.sh

# 3) Right pane: the live runner — each step shows the command and runs it on Enter.
#    It does a quick BEFORE-state pre-check first and stops with a hint if you forgot to set up.
./scripts/1.migrate_to_gateway.sh    # working → convert → ready → handover → recovered

# 4) Clean up (demo resources only)
./scripts/9.cleanup_demo.sh
```

> **Repeating a rehearsal?** After a run, the Gateway holds `.12`. Re-running `0.setup_before.sh`
> alone then **fails** (ingress-nginx can't get `.12`, helm times out). Always reset with
> `9.cleanup_demo.sh` **first**, then `0.setup_before.sh`. The runner's pre-check flags this case.

## How the objects map (Ingress → Gateway API)

A single Ingress used to conflate two things: the *app's routing intent* and *which controller
serves it*. Gateway API splits them into objects owned by different roles:

| Gateway API role | Ingress world | Gateway API world | Namespace |
|---|---|---|---|
| **App routing** (app developer) | **Ingress** `jp-front` | **HTTPRoute** `jp-front` | `default` (app) |
| **L7 entry point** (cluster operator) | — *(implicit in the controller)* | **Gateway** `jp-gateway` | `nginx-gateway` (infra) |
| **Implementation** (infra provider) | ingress-nginx controller | **GatewayClass** `nginx` + NGF controller | cluster / `nginx-gateway` |

So the Ingress's real counterpart is the **HTTPRoute** — same namespace (`default`), same name
(`jp-front`), only the *kind* changes. It is **not** the Gateway. The **Gateway** is a *new* object
Ingress never had as a first-class thing: the explicit **L7 entry point** (its listeners, hostname,
TLS, and IP), owned by the platform / cluster-operator team and living in the infra namespace.

That is why the before/after looks like it "jumps namespaces" but doesn't really: your route stays
in your namespace (`Ingress` → `HTTPRoute`, both `default`), and the Gateway is the infrastructure
layer that moves to where infrastructure belongs. That separation is the core idea of Gateway API.

## Gateway vs its data plane (`jp-gateway` and `jp-gateway-nginx`)

You will see two objects that share a prefix. They are different layers, not duplicates:

| | `jp-gateway` | `jp-gateway-nginx` |
|---|---|---|
| Kind | **Gateway** (Gateway API) | **Service + Deployment** (the actual nginx) |
| Role | the *declaration* ("serve demo.kubecon.jp on :80, IP .12") | the *implementation* that handles traffic |
| Created by | you (`kubectl apply`) | the NGF controller, automatically, as `<gateway>-nginx` |
| Namespace | `nginx-gateway` (infra) | `nginx-gateway` (same as the Gateway) |

The NGF controller (`ngf-nginx-gateway-fabric`) reads the **Gateway** and provisions the
**`jp-gateway-nginx`** data plane to match it — like a Deployment producing its Pods. This split is
the difference from ingress-nginx, where the controller and data plane are one object
(`ingress-nginx-controller`).

That is also why, before the handover, you see:

```
Gateway jp-gateway          PROGRAMMED=True   ADDRESS=(empty)
Service jp-gateway-nginx     EXTERNAL-IP=<pending>
```

`PROGRAMMED=True` means NGF already built the data plane and pushed its config — it is **warm and
waiting**, only without the IP yet (ingress-nginx still holds `.12`). When the handover frees `.12`,
the `jp-gateway-nginx` Service claims it, and the Gateway's `ADDRESS` then reflects the same `.12`.

## Why only simple host/path routing

`ingress2gateway` converts at **full fidelity** for the basic fields (host/path/tls/websocket)
plus canary and gRPC. Things like rewrite, mTLS, header modification, and session affinity are
partially converted or rejected (evidence: gateway-PoC `migration/i2gw/`). A first-migration demo
shows only the cleanest path.

## Demo vs production

This demo is simplified with a **static IP** (local cluster). In real production you implement the
same "zero-downtime recovery" with a **DNS switchover** or a **switch in front of the load balancer**.

## Files

| Path | Contents |
|---|---|
| `manifests/00-backend.yaml` | jp-front app (default namespace) |
| `manifests/01-ingress.yaml` | BEFORE: simple Ingress |
| `manifests/03-gateway-ngf.yaml` | AFTER: i2gw output + same-IP annotation added |
| `scripts/0.setup_before.sh` | Build BEFORE (ingress-nginx + app + pre-warm the Gateway); auto-installs MetalLB + Gateway API CRDs/NGF if missing |
| `scripts/watch_curl.sh` | Left-pane continuous curl |
| `scripts/1.migrate_to_gateway.sh` | Live runner: pre-checks BEFORE state, then shows + runs each step on Enter |
| `scripts/9.cleanup_demo.sh` | Clean up demo resources |
