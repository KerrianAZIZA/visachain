# VisaChain

VisaChain is a decentralized document management and certification system based on **Ethereum smart contracts** and **IPFS**.  
This project was developed as part of a **Master’s degree project** for the course **Internet of Blockchains (IoB)** during the **second year of the Master’s program at Sorbonne University**.

## Academic Context

- **Course:** Internet of Blockchains (IoB)  
- **University:** Sorbonne University  
- **Degree:** Master 2  
- **Instructor:** Maria POTOP-BUTUCARU  
- **Students:**  
  - Kerrian AZIZA  
  - Ihsane BOUBRIK  

## Project Overview

The objective of this project is to design and implement a **blockchain-based system for embassies or institutional actors** to securely share, version, and certify sensitive documents in a decentralized environment.

The system combines:
- **Ethereum smart contracts** for access control, versioning, and certification
- **IPFS (InterPlanetary File System)** for decentralized file storage
- **On-chain metadata** and **off-chain content** referenced via CIDs

This architecture ensures integrity, traceability, and transparency while avoiding centralized storage.

## Repository Structure

visachain/
│
├── README.md
│ Project description and repository documentation
│
├── ipfs_demo.txt
│ Step-by-step commands used to configure multiple IPFS nodes
│ and demonstrate decentralized document storage and retrieval
│
└── contracts/
└── VisaChain.sol
Solidity smart contract implementing the VisaChain logic

### report/report.pdf

This file contains a complete report of the VisaChain with justifications for the implementation and analysis of results.

### contracts/VisaChain.sol

This file contains the core smart contract of the project.  
It implements:
- Document creation and versioning
- Role-based access control (owner, readers, editors, validators)
- On-chain document certification via validator signatures
- Document revocation and ownership transfer
- Read-only helper functions for transparency and auditability

### ipfs_demo.txt

This file documents the experimental setup used for the project:
- Initialization of multiple IPFS nodes (User A, B, C)
- Configuration of distinct API and gateway ports
- Commands used to add files to IPFS
- Demonstration of decentralized storage across independent nodes

It serves as a practical guide to reproduce the IPFS part of the experiment.

## Intended Use

This repository is intended for:
- Academic evaluation
- Demonstration of blockchain and IPFS integration
- Educational purposes related to decentralized systems

It is not intended for production use.

