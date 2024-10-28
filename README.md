# DOCUMENTAÇÃO PARA A INSTALAÇÃO DO SERVIDOR AWS LINUX COM LOAD BALANCER, AUTO SCALING, AMAZON RDS E UMA APLICAÇÃO WORDPRESS EM DOCKER NO AMAZON EFS
**Autor:** Jefferson Gomes Garcia

**Data:** 28 de outubro de 2024

## INTRODUÇÃO

Esta documentação fornece um guia passo a passo para a execução da Atividade AWS – Docker, onde foi solicitada a instalação de um servidor com o Sistema Operacional Linux, que hospedará uma aplicação WordPress em Docker, utilizando o Load Balancer, Auto Scaling, Amazon RDS e o Amazon EFS. Para a execução dessa atividade, utilizaremos o Amazon AWS com a seguinte configuração:

### Configuração do Servidor Utilizado:
- Servidor Cloud hospedado na Amazon WS 
- Amazon Linux 2023 AMI 2023.6.20241010.0 x86_64 HVM kernel-6.1
- Instância EC2 da Família t2.small (1 vCPU, Memória 1 GB)
- 8 GB SSD de Uso Geral (gp3)

## PASSO A PASSO PARA EXECUÇÃO DA ATIVIDADE

1. **Criar a Amazon Virtual Private Cloud (VPC)**:
   - Acesse o painel da VPC na Console da AWS.
   - Clique em **Criar VPC**.
   - Selecione a opção **Somente VPC**.
   - Adicione a Tag de Nome.
   - Defina o bloco e o tamanho CIDR IPv4.
   - Defina o bloco e o tamanho CIDR IPv6.
   - Defina o tipo de Locação em sua VPC.
   - Adicione as Tags.
   - Clique em **Criar VPC**.

2. **Criar Sub-redes**:
   - Acesse a aba **Sub-redes** no Painel da VPC.
   - Clique em **Criar sub-redes**.
   - Selecione o ID da VPC.
   - Defina o nome da sub-rede.
   - Defina a Zona de Disponibilidade.
   - Defina o Bloco CIDR IPv4 da sub-rede.
   - Adicione as Tags.
   - Clique em **Adicionar nova sub-rede** e siga os passos acima.
   - Após criar todas as sub-redes, clique em **Criar sub-rede**.

3. **Criar o Gateway da Internet**:
   - Acesse a aba **Gateways da Internet** no Painel da VPC.
   - Clique em **Criar gateway da Internet**.
   - Defina a Tag de Nome.
   - Adicione as Tags.
   - Clique em **Criar gateway da Internet**.
   - Depois de criado, clique em **Ações** e **Associar à VPC**.
   - Selecione a VPC escolhida e clique em **Associar gateway da Internet**.

4. **Criar a Tabela de Rotas**:
   - Acesse a aba **Tabelas de rotas** no Painel da VPC.
   - Selecione a tabela associada à sua VPC.
   - Na aba **Rotas**, clique em **Editar rotas**.
   - Clique em **Adicionar rotas**.
   - Em **Destino**, inclua `0.0.0.0/0`.
   - Em **Alvo**, escolha **Gateway da Internet** e selecione o seu gateway criado.
   - Clique em **Salvar alterações**.

5. **Criar o Amazon Relational Database Service (RDS)**:
   - Clique em **Criar banco de dados**.
   - Selecione o método de criação do banco de dados; neste caso, utilize a **Criação Padrão**.
   - Selecione o Tipo de mecanismo (uso do MySQL) e a versão mais atual.
   - Selecione o Modelo de exemplo (Nível Gratuito).
   - Em **Configurações**, defina o nome do banco de dados, usuário e senha.
   - Selecione a Classe da Instância de banco de dados.
   - Defina o Tipo e o Tamanho do Armazenamento do banco de dados.
   - Configure a conectividade com a sua VPC e o Grupo de Segurança criados.
   - Clique em **Criar banco de dados**.

6. **Criar o Amazon Elastic File System (EFS)**:
   - Na Console do Amazon EFS, clique em **Criar sistema de arquivos**.
   - Defina um Nome e selecione a sua VPC.
   - Clique em **Criar**.

7. **Criar o Amazon Elastic Compute Cloud (EC2)**:
   - Acesse a Console do Painel EC2.
   - Clique em **Executar instância**.
   - Defina o Nome e as Tags.
   - Escolha a Imagem de aplicação e o sistema operacional.
   - Defina o Tipo da Instância.
   - Crie o Par de chaves para login.
   - Defina a VPC e a Sub-rede que já criamos anteriormente.
   - Crie o Grupo de Segurança, definindo Nome e descrição.
   - Adicione as Regras de Entrada.
   - Defina o tamanho e o tipo de armazenamento.
   - Em **Detalhes Avançados**, inclua o script do `user_data.sh`.
   - Clique em **Executar instância** para criar a primeira.
   - Siga os passos acima para criar uma segunda instância, alterando apenas a sub-rede para uma zona diferente.

8. **Criar uma Amazon AMI**:
   - Acesse o painel das instâncias.
   - Clique no botão **Ações**.
   - Vá até a opção de **Imagens e modelos**.
   - Clique em **Criar imagem**.
   - Defina o nome da imagem e as configurações.
   - Clique em **Criar imagem**.

9. **Criar o nosso template**:
   - Acesse o painel das instâncias.
   - Clique no botão **Ações**.
   - Vá até a opção de **Imagens e modelos**.
   - Clique em **Criar modelo a partir da instância**.
   - Defina o nome do template e as configurações.
   - Clique em **Criar modelo de execução**.

10. **Criar o Grupo de Destino**:
    - Acesse a aba **Balanceamento de Carga** no Painel EC2.
    - Clique em **Grupo de Destino**.
    - Clique em **Criar Grupo de destino**.
    - Selecione a opção de Instância, defina um nome e selecione a sua VPC.
    - Na próxima tela, selecione as instâncias e inclua-as.
    - Clique em **Criar grupo de destino**.

11. **Criar o Load Balancer**:
    - Acesse a aba **Load Balancers** no Painel EC2.
    - Clique em **Criar load balancer**.
    - Escolha **Application Load Balancer** e clique em **Criar**.
    - Defina o Nome do load balancer.
    - Escolha o esquema voltado para Internet.
    - Defina o tipo de endereço IP do balanceador de carga como IPv4.
    - Em **Mapeamento de Rede**, selecione a sua VPC e as Sub-redes.
    - Em **Grupo de Segurança**, selecione o que foi criado.
    - Crie e defina um grupo de destino.
    - Clique em **Criar load balancer**.

12. **Criar o Auto Scaling**:
    - Acesse a aba **Grupos Auto Scaling** no Painel EC2.
    - Clique em **Criar grupo de Auto Scaling**.
    - Defina um Nome para o grupo de Auto Scaling.
    - Selecione um modelo de execução.
    - Defina a VPC que será utilizada.
    - Selecione as Sub-redes.
    - Defina o Balanceador de Carga criado anteriormente.
    - Defina a quantidade mínima e máxima de capacidade de máquinas.
    - Clique em **Criar Auto Scaling**.
