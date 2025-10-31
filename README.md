# My NixOS Configuration ❄️

![NixOS](https://img.shields.io/badge/-NixOS-5277C3?style=flat-square&logo=nixos&logoColor=black) ![Nix](https://img.shields.io/badge/-Nix-7EBAFF?style=flat-square&logo=nixos&logoColor=black)

This is a **highly specialized NixOS configuration**, meticulously crafted over **two years** to ensure redundancy, reliability, and security. NixOS’s declarative nature allows for reproducible and resilient system setups, and this configuration reflects my journey in leveraging those strengths.

> **Note:** I’ve been learning Nix since 2023, and while I’m passionate about this setup, I’m not an expert. Use this configuration as inspiration, but always validate choices for your own needs.
> **Last reviewed:** 31/10/2025 (DD/MM/YYYY)

---

## 🌐 Networking
The networking stack is designed for **security, privacy, and reliability**:

- **Network Management:** Uses `NetworkManager` with `wpa_supplicant` as the backend for wireless networks.
- **DNS:**
  - **DNSSEC** and **DNS-over-TLS** via `Stubby`.
  - **Caching** with `Unbound` for faster and more efficient queries.
- **Time Synchronization:** Uses `chrony` with the **NTS protocol** for secure time synchronization.
- **Firewall:** A robust firewall configuration with **kernel hardening** and **security-focused parameters**.

### Key Files:
| Configuration Area | File Link |
|--------------------|-----------|
| Networking Overview | [/Networking](https://github.com/Masrkai/Nix_Configuration/tree/main/Networking) |
| Firewall Rules | [Firewall.nix](https://github.com/Masrkai/Nix_Configuration/tree/main/Networking/Firewall.nix) |
| Kernel Hardening | [Network_Kernel_Parameters.nix](https://github.com/Masrkai/Nix_Configuration/Networking/hardening/Network_Kernel_Parameters.nix) |
| NetworkManager Hardening | [NetworkManager_hardening.nix](https://github.com/Masrkai/Nix_Configuration/Networking/hardening/NetworkManager_hardening.nix) |
| DNS Caching | [cache.nix](https://github.com/Masrkai/Nix_Configuration/tree/main/Networking/DNS/cache.nix) |
| DNS Resolver | [resolver.nix](https://github.com/Masrkai/Nix_Configuration/tree/main/Networking/DNS/resolver.nix) |

---

## 💻 Programming Language Support
I primarily use **VSCode**, and this configuration includes support for:

- **Languages:** C++, Rust, Python, SQL (MySQL & PostgreSQL servers included).
- **Tools:** Jupyter Notebooks/Server.
- **Development Shells:** C++, Python, JavaScript.

---

## 🤖 AI Workflow
This configuration includes **almost all AI libraries** you might need:

- **Python Libraries:** `scikit-learn`, `PyTorch` (with `torch-bin`), `transformers`, `langchain`, `smolagents`, `flash-attn`, `streamlit`, `gradio`, and more.
- **Configuration File:** [Dev/python.nix](https://github.com/Masrkai/Nix_Configuration/tree/main/Dev/python.nix)

---

## 📂 Configuration Schematic

### 1. Custom Programs
I’ve developed several **custom tools** to streamline workflows:

| Tool | Description | File Link |
|------|-------------|-----------|
| **CTJ** | Converts current images to JPEG | [ctj.py](https://github.com/Masrkai/Nix_Configuration/blob/main/Programs/custom/Python/ctj.py) |
| **MD-PDF** | Converts Markdown files to PDF | [MD-PDF.py](https://github.com/Masrkai/Nix_Configuration/blob/main/Programs/custom/Python/MD-PDF.py) |
| **mac-formatter** | Formats MAC addresses | [mac-formatter.py](https://github.com/Masrkai/Nix_Configuration/blob/main/Programs/custom/Python/mac-formatter.py) |

### 2. Security Configuration
The [security.nix](https://github.com/Masrkai/Nix_Configuration/blob/main/security.nix) file includes:
- Kernel parameter hardening.
- Banned file formats.
- Disabling of the `CUPS` service.

---

## 🔜 More to Come!
This configuration is **constantly evolving**. I’ll be documenting additional features and improvements soon.

---
