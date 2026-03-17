# Daily Driver

> Primary NixOS workstation and homelab host. Runs all security monitoring VMs, ships logs to the SIEM, and serves as the local LLM interface — fully declarative and version-controlled.

Part of the [Homelab Security Stack](https://github.com/impulseSecDev/NIX-HOMELAB-SECURITY-STACKk).

---

## Overview

The daily driver is both a personal workstation and the physical host for the homelab's security monitoring infrastructure. All VMs — ELK, Wazuh, and Vaultwarden — run as KVM/QEMU guests managed via libvirt. The machine itself participates in the homelab as a monitored host, shipping its own logs to Elasticsearch and running a Wazuh agent for host-based intrusion detection.

The entire system state is declared in NixOS configuration. Reproducible from scratch — no manual setup steps, no configuration drift.

---

## Stack

| Component | Method | Purpose |
|---|---|---|
| KVM/QEMU | NixOS virtualisation module | Hosts all homelab VMs |
| OpenWebUI | NixOS service | Local LLM interface, Tailscale-only access |
| Wazuh Agent | NixOS service | Host monitoring, FIM, alert shipping |
| Fluent Bit | Native NixOS module | System log shipping to Elasticsearch |
| WireGuard | Native NixOS module | wg0 log shipping tunnel to VPS hub |
| Nginx | Native NixOS module | HTTPS reverse proxy, TLS termination on Tailscale interface |
| Tailscale | Native NixOS module | Zero trust mesh, admin access, SSH |
| sops-nix | — | Encrypted secrets management |

---

## Hosted VMs

| VM | Repo | Role |
|---|---|---|
| ELK VM | [ELK-NIXVM](https://github.com/impulseSecDev/ELK-NIXVM) | Elasticsearch, Kibana, Fluent Bit — SIEM core |
| Wazuh VM | [WAZUH-NIXVM](https://github.com/impulseSecDev/WAZUH-NIXVM) | Wazuh Manager — HIDS core |
| Vaultwarden VM | [VW-NIXVM](https://github.com/impulseSecDev/VW-NIXVM) | Self-hosted password manager |

---

## Network

### Tailscale

The daily driver is a full member of the Tailscale mesh coordinated by the self-hosted Headscale server. All admin traffic, SSH access, and internal service communication routes over Tailscale. OpenWebUI is accessible exclusively over the Tailscale interface — not reachable from the public internet.

### WireGuard

Two dedicated WireGuard interfaces, each with a specific purpose:

- `wg0` — log shipping only. Fluent Bit and the Wazuh agent ship over this interface to the VPS hub which forwards to the appropriate VM. Deliberately separated from the Tailscale admin channel.
- `wg1` — SSH access to the VPS only. No port 22 exposed publicly.

```
Daily Driver (wg0) ──── WireGuard ──── VPS hub ──── ELK VM / Wazuh VM
                     log shipping only, outbound

Daily Driver (wg1) ──── WireGuard ──── VPS
                     SSH access only
```

---

## NixOS Module Structure

```
nixos/
├── configuration.nix        # Entry point, imports all modules
├── hardware-configuration.nix
├── flake.nix
├── vms.nix                  # KVM/QEMU, libvirt, VM definitions
├── openwebui.nix            # OpenWebUI service
├── nginx.nix                # HTTPS reverse proxy, Tailscale-only TLS termination
├── fluent-bit.nix           # Fluent Bit with sops template
├── wireguard.nix            # wg0 log shipping, wg1 SSH tunnel
├── tailscale.nix            # Tailscale mesh config
├── wazuh-agent.nix          # Wazuh agent, enrollment config
├── sops.nix                 # sops-nix configuration
└── secrets/
    └── secrets.yaml         # sops-encrypted secrets (safe to commit)
```

---

## OpenWebUI

A self-hosted local LLM interface running on the daily driver. Accessible only over the Tailscale mesh — Nginx terminates TLS on the Tailscale interface using the `*.mesh.yourdomain.com` wildcard certificate provisioned via `security.acme`. No public internet exposure.

```
Tailnet member → Tailscale → Nginx (HTTPS, Tailscale interface) → OpenWebUI
```

---

## Defense in Depth

- Wazuh agent monitors the host itself — FIM on config files, rootkit detection, SCA
- Fluent Bit ships all system and journal logs to Elasticsearch over WireGuard
- OpenWebUI not exposed publicly — Tailscale-only access
- Log shipping deliberately separated from admin traffic via dedicated WireGuard interface
- sops-nix encrypted secrets — no plaintext credentials in version control
- All VM traffic isolated within libvirt bridge network
- Tailscale configured with ACL rules for limited ssh access by nodes with admin tags.

---

## Tech Stack

`NixOS` `KVM/QEMU` `libvirt` `WireGuard` `Tailscale` `Nginx` `Fluent Bit` `Wazuh` `OpenWebUI` `sops-nix` `ACME / Let's Encrypt` `Cloudflare DNS-01` `Declarative infrastructure` `Log aggregation` `HIDS`
