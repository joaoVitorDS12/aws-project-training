# Infraestrutura AWS com Terraform

Infraestrutura provisionada na AWS utilizando Terraform, simulando um ambiente real de produção com foco em escalabilidade, confiabilidade e boas práticas de engenharia. O próprio portfólio que documenta este projeto está hospedado nesta infraestrutura.

🌐 **[Ver portfólio ao vivo](https://d35xpuot06haku.cloudfront.net)**

---

## Arquitetura

```
Usuário → CloudFront → S3 (frontend Next.js)
                    → ALB → Auto Scaling Group → EC2
```

### Componentes

- **CloudFront** — CDN global com URL rewrite para suporte a rotas do Next.js
- **S3** — Armazenamento do frontend estático com acesso exclusivo via CloudFront (OAC)
- **Application Load Balancer (ALB)** — Distribui o tráfego entre as instâncias EC2 com health checks
- **Auto Scaling Group (ASG)** — Mantém disponibilidade com mínimo de 2 instâncias e escala até 3
- **EC2** — Instâncias rodando Apache com conteúdo servido via S3
- **IAM** — Role e policy com princípio do menor privilégio para acesso EC2 → S3
- **Security Groups** — Controle de tráfego entre ALB e EC2

---

## Decisões técnicas

**Separação entre infraestrutura e aplicação**
O Terraform provisiona o ambiente de forma independente da aplicação, permitindo versionamento e reprodutibilidade separados.

**Uso do Application Load Balancer**
O ALB foi escolhido para distribuir tráfego entre instâncias, suportar health checks e permitir evolução futura com múltiplos serviços.

**Frontend via S3 + CloudFront com OAC**
O bucket S3 é privado — o acesso público é bloqueado e o CloudFront acessa via Origin Access Control (OAC), seguindo boas práticas de segurança da AWS.

**CloudFront Function para roteamento SPA**
Uma CloudFront Function reescreve as URLs no edge, garantindo que rotas do Next.js como `/projetos/infra-aws` sejam corretamente resolvidas para `index.html`.

**Infrastructure as Code com Terraform**
Toda a infraestrutura é versionada e pode ser recriada com `terraform apply`, facilitando manutenção e reprodutibilidade.

---

## Stack

`Terraform` `AWS` `EC2` `ALB` `Auto Scaling` `CloudFront` `S3` `IAM` `Next.js` `GitHub Actions`

---

## Estrutura do projeto

```
.
├── infra/                  # Terraform
│   ├── main.tf
│   ├── provider.tf
│   ├── variables.tf
│   ├── output.tf
│   ├── locals.tf
│   ├── compute.tf          # EC2, ASG, Launch Template
│   ├── load_balancer.tf    # ALB, Target Group
│   ├── network.tf          # VPC, Security Groups
│   ├── cdn.tf              # CloudFront + Function
│   ├── storage.tf          # S3 + OAC + Bucket Policy
│   ├── iam.tf              # Role, Policy, Instance Profile
│   └── security.tf
├── web/                    # Frontend Next.js (portfólio)
│   ├── app/
│   └── ...
└── .github/
    └── workflows/
        └── deploy.yml      # CI/CD: build Next.js + upload S3 + invalidação CloudFront
```

---

## CI/CD

O pipeline no GitHub Actions é disparado a cada push na branch `main` e executa:

1. Build do Next.js (`npm run build`)
2. Upload dos arquivos estáticos para o S3 (`aws s3 sync`)
3. Invalidação do cache do CloudFront

---

## Como reproduzir

### Pré-requisitos

- [Terraform](https://developer.hashicorp.com/terraform/install) instalado
- AWS CLI configurado com credenciais válidas
- VPC e subnets existentes na sua conta AWS

### Deploy da infraestrutura

```bash
cd infra
terraform init
terraform apply
```

### Variáveis necessárias

Crie um arquivo `terraform.tfvars` na pasta `infra/`:

```hcl
vpc_id  = "vpc-xxxxxxxxxxxxxxxxx"
subnets = ["subnet-xxxxxxxxxxxxxxxxx", "subnet-xxxxxxxxxxxxxxxxx"]
```

### Outputs gerados

Após o apply, o Terraform retorna:

| Output | Descrição |
|---|---|
| `cloudfront_url` | URL do portfólio |
| `alb_dns_name` | DNS do Load Balancer |
| `bucket_name` | Nome do bucket S3 |
| `cloudfront_distribution_id` | ID da distribuição CloudFront |
| `asg_name` | Nome do Auto Scaling Group |

### Secrets necessárias no GitHub

| Secret | Descrição |
|---|---|
| `AWS_ACCESS_KEY_ID` | Credencial AWS |
| `AWS_SECRET_ACCESS_KEY` | Credencial AWS |
| `AWS_REGION` | Região (ex: `us-east-1`) |
| `S3_BUCKET` | Valor do output `bucket_name` |
| `CLOUDFRONT_DISTRIBUTION_ID` | Valor do output `cloudfront_distribution_id` |

---

## Destruir a infraestrutura

```bash
cd infra
terraform destroy
```
