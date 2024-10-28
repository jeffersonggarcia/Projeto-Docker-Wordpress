#!/bin/bash
set -e

# Atualizar o sistema
echo "Atualizando o sistema..."
sudo yum update -y

# Instalar o Docker se não estiver instalado
if ! command -v docker &> /dev/null; then
    echo "Instalando o Docker..."
    sudo yum install -y docker
fi

# Iniciar o serviço do Docker
echo "Iniciando o serviço do Docker..."
sudo systemctl start docker
sudo systemctl enable docker

# Verificar se o Docker está em execução
sudo systemctl status docker || {
    echo "O Docker não está em execução."
    exit 1
}

# Adicionar o usuário ec2-user ao grupo docker
echo "Adicionando ec2-user ao grupo docker..."
sudo usermod -aG docker ec2-user

# Aguardar o Docker estar pronto
sleep 5

# Instalar amazon-efs-utils se não estiver instalado
if ! command -v mount.efs &> /dev/null; then
    echo "Instalando amazon-efs-utils..."
    sudo yum install -y amazon-efs-utils
fi

# Instalar o Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "Instalando o Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Verificar a instalação do Docker Compose
docker-compose --version || {
    echo "Falha na instalação do Docker Compose."
    exit 1
}

# Montar o EFS
if ! mount | grep -q '/mnt/efs'; then
    echo "EFS não está montado. Montando agora..."
    sudo mkdir -p /mnt/efs
    sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-0afbc6bdf0f2f258e.efs.us-east-1.amazonaws.com:/ /mnt/efs || {
        echo "Falha ao montar o EFS."
        exit 1
    }
    echo "EFS montado em /mnt/efs."

    # Adicionar entrada no /etc/fstab para montagem automática
    echo "Configurando montagem automática do EFS no /etc/fstab..."
    echo "fs-0afbc6bdf0f2f258e.efs.us-east-1.amazonaws.com:/ /mnt/efs nfs4 defaults,_netdev 0 0" | sudo tee -a /etc/fstab
fi

# Configurar permissões do EFS
echo "Configurando permissões para /mnt/efs..."
sudo chown -R ec2-user:ec2-user /mnt/efs

# Criar arquivo docker-compose.yml dentro do EFS
echo "Criando arquivo docker-compose.yml dentro do EFS..."
sudo mkdir -p /mnt/efs/docker
cat <<EOF > /mnt/efs/docker/docker-compose.yml
services:

  wordpress:
    image: wordpress
    restart: always
    ports:
      - 80:80
    environment:
      WORDPRESS_DB_HOST: rds-projectdoker.cr60uiogqo0p.us-east-1.rds.amazonaws.com
      WORDPRESS_DB_USER: mysql_wordpress
      WORDPRESS_DB_PASSWORD: dockerwordpress
      WORDPRESS_DB_NAME: docker_wordpress
    volumes:
      - /mnt/efs:/var/www/html

volumes:
  wordpress:
EOF

# Iniciar o Docker Compose
echo "Iniciando o contêiner WordPress com Docker Compose..."
cd /mnt/efs/docker
docker-compose up -d >> docker-compose.log 2>&1 || {
    echo "Falha ao iniciar o contêiner WordPress."
    exit 1
}

echo "Contêiner WordPress iniciado com sucesso!"

