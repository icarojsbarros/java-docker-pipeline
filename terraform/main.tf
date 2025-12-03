# 1. PROVIDER: fornecedor da infra? (AWS)

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-east-1" # Região Norte da Virginia
}


# 2. RESOURCE: Uma instância EC2

resource "aws_instance" "app_server" {
  ami           = "ami-0c7217cdde317cfec" # Imagem Ubuntu 22.04 LTS (Free Tier)
  instance_type = "t2.micro"              # Gratuito


  # 3. USER DATA: Script irá rodar quando a instância ligar pela primeira vez
  # Conectamos o Docker com a AWS!

  user_data = <<-EOF
              #!/bin/bash
              # Atualiza o sistema
              sudo apt-get update
              
              # Instala o Docker
              sudo apt-get install -y docker.io
              sudo systemctl start docker
              sudo systemctl enable docker
              
              # Baixa e roda a aplicação direto do GitHub Registry
              # O parametro -p 80:80 expõe a porta 80 (HTTP)
              sudo docker run -d -p 80:80 ghcr.io/icarojsbarros/java-docker-pipeline:latest
              EOF


  # Tags para organização

  tags = {
    Name    = "Servidor-Java-Docker"
    Project = "Laboratorio DevOps"
  }
}


# 4. OUTPUT: IP Público da instância

output "public_ip" {
  description = "IP publico do servidor para acesso"
  value       = aws_instance.app_server.public_ip
}