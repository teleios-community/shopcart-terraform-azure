# Teleios E-Commerce Infrastructure - Azure Implementation

This repository contains the Terraform infrastructure code for deploying the Teleios e-commerce platform on Microsoft Azure. It follows enterprise best practices with modular design, environment-specific configurations, and Terraform Cloud integration.

## 🏗️ Architecture Overview

This implementation creates a scalable e-commerce platform supporting development, staging, and production environments with:

- **Networking**: Virtual Network with public/private subnets, Network Security Groups, Application Gateway, NAT Gateway
- **Compute**: Virtual Machine Scale Sets, Azure Container Instances, App Service, Azure Functions  
- **Data**: Azure SQL Database, Azure Cache for Redis, Storage Accounts, Cosmos DB

## 📁 Repository Structure

```
shopcart-terraform-azure/
├── # SHARED CONFIGURATION
├── terraform.tf              # Terraform Cloud workspace configuration
├── variables.tf              # All variable definitions
├── locals.tf                 # Common local values and logic
├── outputs.tf                # All environment outputs
├── data.tf                   # Common data sources
│
├── # RESOURCE FILES
├── resource-group.tf         # Resource Group module consumption
├── vnet.tf                   # Virtual Network module consumption
├── nsg.tf                    # Network Security Groups module consumption
├── app-gateway.tf            # Application Gateway module consumption
├── nat-gateway.tf            # NAT Gateway module consumption
├── vm.tf                     # Virtual Machine Scale Set module consumption
├── container-instances.tf    # Container Instances module consumption
├── app-service.tf            # App Service module consumption
├── functions.tf              # Azure Functions module consumption
├── sql.tf                    # SQL Database module consumption
├── redis.tf                  # Redis Cache module consumption
├── storage.tf                # Storage Account module consumption
├── cosmos-db.tf              # Cosmos DB module consumption
│
└── # ENVIRONMENT CONFIGS
    └── environments/
        ├── dev.tfvars        # Development configuration
        ├── staging.tfvars    # Staging configuration
        └── prod.tfvars       # Production configuration
```

## 🚀 Quick Start

### Prerequisites

1. **Terraform Cloud Account**: Set up workspaces for dev, staging, and prod
2. **Azure Subscription**: Active Azure subscription with contributor access
3. **Module Access**: Access to Teleios private module registry

### Environment Setup

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd shopcart-terraform-azure
   ```

2. **Configure Terraform Cloud Variables**:
   Set these sensitive variables in your Terraform Cloud workspace:
   - `TF_VAR_sql_administrator_password` (sensitive)
   - `TF_VAR_vm_admin_password` (sensitive)
   - `ARM_CLIENT_ID` (Azure Service Principal)
   - `ARM_CLIENT_SECRET` (Azure Service Principal Secret)
   - `ARM_SUBSCRIPTION_ID` (Azure Subscription ID)
   - `ARM_TENANT_ID` (Azure Tenant ID)

3. **Initialize Terraform**:
   ```bash
   terraform init
   ```

### Deployment Commands

#### Development Environment
```bash
terraform plan -var-file="environments/dev.tfvars"
terraform apply -var-file="environments/dev.tfvars"
```

#### Staging Environment  
```bash
terraform plan -var-file="environments/staging.tfvars"
terraform apply -var-file="environments/staging.tfvars"
```

#### Production Environment
```bash
terraform plan -var-file="environments/prod.tfvars"
terraform apply -var-file="environments/prod.tfvars"
```

## 🎯 Environment Configurations

### Development (`dev.tfvars`)
- **Cost-optimized**: Basic SKUs, minimal redundancy
- **VM Scale Set**: B1s instances, 1-2 capacity
- **SQL Database**: Basic tier, 2GB
- **Redis**: Basic tier, C0 cache
- **Storage**: Local redundancy (LRS)

### Staging (`staging.tfvars`)
- **Intermediate scale**: Standard SKUs, zone redundancy
- **VM Scale Set**: B2s instances, 2-5 capacity  
- **SQL Database**: S1 tier, 100GB
- **Redis**: Standard tier, C1 cache
- **Storage**: Zone redundancy (ZRS)

### Production (`prod.tfvars`)
- **Production-ready**: Premium SKUs, geo-redundancy
- **VM Scale Set**: D2s_v3 instances, 3-20 capacity
- **SQL Database**: S3 tier, 500GB
- **Redis**: Premium tier, P1 cache
- **Storage**: Geo redundancy (GRS)

## 🔧 Module Dependencies

The infrastructure components have explicit dependencies:

```
Resource Group
    ↓
Virtual Network → Network Security Groups
    ↓                    ↓
App Gateway ←→ VM Scale Set ←→ Storage Account
    ↓                    ↓           ↓
Container Instances  App Service  Functions
    ↓                    ↓           ↓
SQL Database ←→ Redis Cache ←→ Cosmos DB
```

## 🔐 Security Considerations

- **Network Segmentation**: Separate subnets for web, app, and data tiers
- **Security Groups**: Restrictive rules with least privilege access
- **Secrets Management**: Sensitive data stored in Terraform Cloud variables
- **SSL/TLS**: HTTPS enforced across all public endpoints

## 📊 Cost Optimization

- **Environment Scaling**: Appropriate sizing for each environment
- **Auto Scaling**: Dynamic scaling based on demand
- **Reserved Instances**: Consider for production workloads
- **Storage Tiers**: Appropriate replication levels per environment

## 🔄 CI/CD Integration

This repository integrates with Terraform Cloud for:
- **Automated Planning**: Pull request triggered plans
- **Secure Apply**: Protected production deployments
- **State Management**: Remote state with locking
- **Variable Management**: Centralized sensitive data

## 📈 Monitoring & Observability

Post-deployment monitoring setup:
- **Application Insights**: Application performance monitoring
- **Azure Monitor**: Infrastructure metrics and logs
- **Log Analytics**: Centralized logging
- **Alerts**: Proactive issue detection

## 🤝 Contributing

1. Create feature branch from main
2. Make changes following established patterns
3. Test changes in development environment
4. Submit pull request with detailed description
5. Ensure all CI/CD checks pass

## 📞 Support

- **Team**: Teleios DevOps Team
- **Documentation**: See `/docs` directory
- **Issues**: Create GitHub issues for bugs/features

---

**Built with ❤️ by the Teleios DevOps Team**
