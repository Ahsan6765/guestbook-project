
Execute the Containers

Go ahead and stand up your newly optimized, multi-tier application stack. From your terminal inside the app/ folder, run:
bash
docker compose up --build


=============================================

Dir Structure Approach


azure-aca-infrastructure/
│
├── bootstrap/
│   ├── main.tf
│   ├── variables.tf
│   ├── providers.tf
│   └── outputs.tf
│
├── modules/
│   │
│   ├── networking/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── network-security/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── container-registry/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── key-vault/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── managed-identity/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── log-analytics/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── container-apps-environment/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── container-app/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   └── mysql/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
├── environments/
│   │
│   └── dev/
│       ├── main.tf
│       ├── providers.tf
│       ├── variables.tf
│       ├── outputs.tf
│       ├── terraform.tfvars.example
│       └── backend.tf
│
├── .github/
│   └── workflows/
│       └── terraform.yml
│
├── .gitignore
└── README.md
