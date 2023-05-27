# Guia Terraform

## Escopo do projeto:

Este projeto tem como objetivo principal a criação de um script terraform que gera a infraestrutura necessária na AWS (Amazon Web Services) para a captura, demodulação e processamento de dados do satélite norte americano AQUA, junto com a criação de alarmes da cloudwatch para o monitoramento do processo todo. A infraestrutura original foi provida por este guia da AWS: https://aws.amazon.com/blogs/publicsector/earth-observation-using-aws-ground-station/, criado pela própria amazon. O conteúdo deste projeto vai até a etapa “Processor Instance Configuration – IPOPP”, a partir deste ponto, será necessário manualmente se conectar nas máquinas da amazon, e seguir o guia original.

O satélite AQUA, lançado em 2002 como parte do programa Earth Science Data Systems (ESDS) da NASA, desempenha um papel fundamental na coleta de informações sobre o sistema terrestre. A infraestrutura proposta utiliza a AWS Ground Station para estabelecer a comunicação com o satélite e receber os sinais de radiofrequência decodificados. Em seguida, os dados decodificados são transmitidos para instâncias EC2 dedicadas ao processamento, onde são gerados produtos de dados em diferentes níveis, como arquivos HDF e imagens TIFF. Esses produtos são armazenados de forma segura no bucket S3 da AWS, permitindo seu posterior uso e compartilhamento com os assinantes de dados.

Além disso, o projeto inclui a configuração do CloudWatch para monitorar de forma proativa a utilização de recursos da AWS, tais como as instâncias EC2 e o armazenamento S3. Serão criados alarmes personalizados para notificar os administradores caso a utilização de CPU ou memória das instâncias EC2 ultrapasse limites predefinidos, garantindo assim a estabilidade e o desempenho do ambiente de processamento de dados. Também será monitorada a quantidade de armazenamento utilizado no S3, visando garantir uma gestão adequada dos dados recebidos do satélite. Adicionalmente, o monitoramento será estendido aos recursos criados pelos CloudFormation stacks, fornecendo uma visão abrangente do ambiente e permitindo a identificação rápida de qualquer problema relacionado à infraestrutura.

## Infraestrutura necessária:

### Dependencias:

1. Conta da AWS: É necessário ter uma conta na AWS para criar e gerenciar recursos na nuvem. Se você ainda não tem uma conta, pode criar uma gratuitamente em **[https://aws.amazon.com/pt/free](https://aws.amazon.com/pt/free)**.
2. Chave de Acesso da AWS: Para interagir com a AWS, você precisará de uma chave de acesso (Access Key) e uma chave secreta (Secret Key). Essas informações serão usadas para autenticar suas solicitações na AWS.
3. AWS CLI instalado e funcionando

Instalação e Configuração:
Siga os passos abaixo para instalar e configurar o ambiente de trabalho:

Terraform:

1. Chave de acesso da AWS: Acesse o Console de Gerenciamento da AWS e faça login em sua conta. Em seguida, vá para o serviço IAM (Identity and Access Management) e crie uma chave de acesso para o usuário que será usado com o Terraform. Anote a chave de acesso e a chave secreta, pois você precisará delas mais adiante.
2. siga o guia da hashiCorp para a instalação do terraform e configuração do docker:
[https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
3. Configuração das variáveis de ambiente: Para facilitar o uso do container Docker, é recomendado configurar algumas variáveis de ambiente. Execute os seguintes comandos no terminal ou prompt de comando:
    
    ```jsx
    
    export AWS_ACCESS_KEY_ID = <sua_access_key>
    export AWS_SECRET_ACCESS_KEY = <sua_secret_key>
    ```
    
    Substitua **`<sua_access_key>`** e **`<sua_secret_key>`** pelos valores correspondentes da sua chave de acesso da AWS.
    

AWS CLI:

Para baixar, instalar e configurar a AWS Command Line Interface (CLI), siga as etapas a seguir:

1. Baixe a AWS CLI: Acesse o site oficial da AWS CLI (**[https://aws.amazon.com/cli/](https://aws.amazon.com/cli/)**) e faça o download da versão compatível com o seu sistema operacional.
2. Instale a AWS CLI: Após o download, execute o instalador e siga as instruções específicas para o seu sistema operacional. A instalação pode ser feita de forma automática ou manual, dependendo do sistema operacional.
3. Configure a AWS CLI: Abra o terminal ou prompt de comando e execute o comando "aws configure". Será solicitado que você insira suas credenciais da AWS, incluindo a Access Key ID e a Secret Access Key. Essas informações podem ser obtidas no Console de Gerenciamento da AWS.
4. Escolha a região padrão: Após inserir suas credenciais, você será solicitado a escolher uma região padrão para a AWS CLI. Selecione a região desejada com base na sua localização ou nos serviços da AWS que você pretende utilizar.
5. Configuração concluída: Após a configuração, você receberá uma confirmação de que a AWS CLI está pronta para uso. Você pode executar comandos da

### Onboarding do satélite:

Para iniciar o processo de recebimento dos dados do satélite AQUA na AWS Ground Station, é necessário realizar o processo de "onboarding" do satélite em sua conta AWS. Para isso, envie um e-mail para [aws-groundstation@amazon.com](mailto:aws-groundstation@amazon.com) solicitando a adição do AQUA à Ground Station em sua conta AWS. Certifique-se de incluir o número da sua conta AWS e fazer referência ao AQUA e seu NORAD ID (27424). Após o sucesso do processo de "onboarding", o satélite estará visível no Console da Ground Station ou por meio da AWS CLI, permitindo que você gerencie e acesse os dados recebidos do AQUA. Essa etapa é essencial pois somente assim que se tem acesso ao satélite AQUA dentro da Ground Station.

### Softwares da NASA:

Para processar os dados RAW dos satélites americanos, é necessário criar uma conta no site da [DRL](https://directreadout.sci.gsfc.nasa.gov/loginDRL.cfm?cid=325&type=software) (Data Reception and Processing for Low Earth Orbiting Satellites) da NASA. Após criar a conta, é preciso baixar os programas "RT-STPS" e "IPOPP". Esses softwares são responsáveis por tratar e processar os dados RAW em diferentes níveis, desde o nível L0 (RT-STPS) até os níveis L1, L2 e L3 (IPOPP). Para obter mais informações sobre os diferentes níveis de dados, recomenda-se consultar o [site da NASA](https://earthdata.nasa.gov/collaborate/open-data-services-and-software/data-information-policy/data-levels).

Depois de baixar os programas, salve-os em uma pasta dentro do diretório dos arquivos do Terraform e altere os nomes dos destinos de acordo no arquivo. Para este guia, deixaremos os arquivos dentro da seguinte estrutura: nasa_files/software/<nome do programa aqui>. Garanta que a pasta nasa _files esteja dentro do diretório com os outros arquivos terraform.

Por questões de segurança, a NASA definiu que o software IPOPP deve ser baixado e executado na mesma máquina, dentro de um período de 24 horas a partir do download inicial. Para utilizarmos esse software na instância EC2, será necessário fazer o SSH para a própria instância, baixar e executar o programa diretamente na máquina. Com isso em mente, não há necessidade de baixá-lo nesta etapa inicial.

### Policies da AWS:

garanta que seu usuário da AWS tem a role **AmazonS3FullAccess.**

# Terraform:

Para rodar os arquivos,  rode os seguintes comandos:

```python
terraform init
```

Usado para inicializar um diretório de trabalho do Terraform. Ele é executado uma vez em cada novo diretório de projeto do Terraform ou quando há alterações no provedor de infraestrutura. Durante a inicialização, o Terraform verifica e faz o download das dependências necessárias, como provedores de recursos e módulos, para que o ambiente de execução esteja pronto para uso.

```python
terraform plan -out plano
```

Usado para criar um plano de execução que descreve as ações que o Terraform executará para atingir o estado desejado da infraestrutura. O argumento **`-out plano`** é opcional e permite salvar o plano em um arquivo para uso posterior. O plano exibe uma visão geral das alterações propostas, incluindo criação, modificação ou exclusão de recursos, além de fornecer informações sobre quaisquer dependências ou conflitos identificados.

```python
terraform apply "plano
```

Usado para aplicar as alterações definidas no plano criado anteriormente. O argumento "plano" especifica o arquivo de plano a ser usado para a execução das alterações. Ao executar o comando, o Terraform solicitará uma confirmação antes de fazer as alterações na infraestrutura. Uma vez confirmado, o Terraform executará as ações necessárias para criar, modificar ou excluir recursos, conforme especificado no plano. Esse comando é a etapa final para efetivar as mudanças na infraestrutura.

Os arquivos terraform foram divididos da seguinte maneira:

### main.tf:

```python
# Configure the AWS Provider
provider "aws" {
  version = "~> 3.37"
  region  = "us-east-1"
}

# Criando bucket para salvar o Estado da Infraestrutura
terraform {
  backend "s3" {
    bucket  = "<your-bucket-name-here>"
    key     = "terraform.tsstate"
    region  = "us-east-1"
    encrypt = true
  }
}
```

Arquivo principal do código, configura o provedor AWS e define a versão e a região a serem usadas. Para configurar o bloco para o usuário, é necessário substituir o valor "us-east-1" pela região desejada, caso não seja a região padrão desejada. Por exemplo, se o usuário deseja usar a região "sa-east-1" (São Paulo), deve substituir "us-east-1" por "sa-east-1".

Em seguida, o bloco de código cria um bucket no Amazon S3 para armazenar o estado da infraestrutura do Terraform. Para configurar o bloco, é necessário substituir o valor "<your-bucket-name-here>" pelo nome desejado para o bucket. Certifique-se de escolher um nome único, pois os nomes dos buckets do S3 são globais. Além disso, é possível alterar o valor de "terraform.tsstate" para o nome de chave desejado para o arquivo de estado do Terraform.

Por fim, caso deseje desativar a criptografia do estado do Terraform, basta alterar o valor de "encrypt" para "false". No entanto, é recomendável manter a criptografia ativada para garantir a segurança dos dados sensíveis do estado da infraestrutura.

### s3_bucket.tf

```bash
# Create an S3 bucket
resource "aws_s3_bucket" "bucket" {
  bucket = "<SEU-BUCKET-AQUI>"
}
```

Criamos o S3 bucket necessario para todo o processo, os arquivos necessários serão salvos neste bucket, junto com os dados finais.

```
resource "aws_vpc" "vpc" {
  cidr_block = "172.16.0.0/20" #enter the CIDR block you want to use for the VPC
  tags = {
    Name = "VPC_AQUA"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "internet-gateway"
  }
}

# Create Route Table
resource "aws_route_table" "table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "route-table"
  }
}

#then create a subnet
resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "172.16.0.0/24" #enter the CIDR block you want to use for the subnet
  availability_zone       = "us-east-1a" #enter the availability zone you want to use for the subnet
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet_AQUA"
  }
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "router_table" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.table.id
}resource "aws_vpc" "vpc" {
  cidr_block = "172.16.0.0/20" #enter the CIDR block you want to use for the VPC
  tags = {
    Name = "VPC_AQUA"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "internet-gateway"
  }
}

# Create Route Table
resource "aws_route_table" "table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "route-table"
  }
}

#then create a subnet
resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "172.16.0.0/24" #enter the CIDR block you want to use for the subnet
  availability_zone       = "us-east-1a" #enter the availability zone you want to use for the subnet
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet_AQUA"
  }
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "router_table" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.table.id
}
```

### Upload de arquivos para o S3 bucket:

Para poder processar os dados de AQUA, sera necessario fazer upload de multiplos arquivos. alguns já estão baixados dentro da pasta nasa _files, enquanto outros virão de um s3 criado pela equipe da amazon, para facilitar o processo de demodulação e processamento dos dados do satélite, os arquivos copiados do s3 pré existente começam com o endereço: s3://aws-gs-blog/software/data-receiver/ 

Estamos copiando os seguintes arquivos do S3:

- receivedata.py
- awsgs.py
- start-data-capture.sh
- ipopp-ingest.sh
- install-ipopp.sh

```python
# Copiar o arquivo RT-STPS_7.0.tar.gz para o bucket S3
resource "null_resource" "copy_RT_STPS_7_0" {
  provisioner "local-exec" {
    command = "aws s3 cp nasa_files/software/RT-STPS/RT-STPS_7.0.tar.gz s3://<SEU-BUCKET-AQUI>/software/RT-STPS/"
  }
}

# Copiar o arquivo RT-STPS_7.0_PATCH_1.tar.gz para o bucket S3
resource "null_resource" "copy_RT_STPS_7_0_PATCH_1" {
  provisioner "local-exec" {
    command = "aws s3 cp nasa_files/software/RT-STPS/RT-STPS_7.0_PATCH_1.tar.gz s3://<SEU-BUCKET-AQUI>/software/RT-STPS/"
  }
}

# Copiar o arquivo receivedata.py para o bucket S3 com permissões bucket-owner-full-control
resource "null_resource" "copy_receivedata_py" {
  provisioner "local-exec" {
    command = "aws s3 cp --acl bucket-owner-full-control s3://aws-gs-blog/software/data-receiver/receivedata.py s3://<SEU-BUCKET-AQUI>/software/data-receiver/ --source-region us-east-2 --region us-east-1"
  }
}

# Copiar o arquivo awsgs.py para o bucket S3 com permissões bucket-owner-full-control
resource "null_resource" "copy_awsgs_py" {
  provisioner "local-exec" {
    command = "aws s3 cp --acl bucket-owner-full-control s3://aws-gs-blog/software/data-receiver/awsgs.py s3://<SEU-BUCKET-AQUI>/software/data-receiver/ --source-region us-east-2 --region us-east-1"
  }
}

# Copiar o arquivo start-data-capture.sh para o bucket S3 com permissões bucket-owner-full-control
resource "null_resource" "copy_start_data_capture_sh" {
  provisioner "local-exec" {
    command = "aws s3 cp --acl bucket-owner-full-control s3://aws-gs-blog/software/data-receiver/start-data-capture.sh s3://<SEU-BUCKET-AQUI>/software/data-receiver/ --source-region us-east-2 --region us-east-1"
  }
}

# Copiar o arquivo ipopp-ingest.sh para o bucket S3 com permissões bucket-owner-full-control
resource "null_resource" "copy_ipopp_ingest_sh" {
  provisioner "local-exec" {
    command = "aws s3 cp --acl bucket-owner-full-control s3://aws-gs-blog/software/IPOPP/ipopp-ingest.sh s3://<SEU-BUCKET-AQUI>/software/IPOPP/ --source-region us-east-2 --region us-east-1"
  }
}

# Copiar o arquivo install-ipopp.sh para o bucket S3 com permissões bucket-owner-full-control
resource "null_resource" "copy_install_ipopp_sh" {
  provisioner "local-exec" {
    command = "aws s3 cp --acl bucket-owner-full-control s3://aws-gs-blog/software/IPOPP/install-ipopp.sh s3://<SEU-BUCKET-AQUI>/software/IPOPP/ --source-region us-east-2 --region us-east-1"
  }
}
```

Cada bloco apenas executa o comando no seu terminal, todos os comandos são para o CLI da AWS.

### cloud_formation_stacks.tf:

```python
# Cloud Formation 1: Creating a stack for defining the Mission Profile
resource "aws_cloudformation_stack" "mission_profile" {
  name = "<your-stack-name-here>"
  template_url = "https://aws-gs-blog.s3.us-east-2.amazonaws.com/cfn/aqua-rt-stps.yml"

  parameters = {
    CreateReceiverInstance = "false"
    InstanceType           = "m5.4xlarge"
    S3Bucket               = aws_s3_bucket.bucket.id
    SSHCidrBlock           = "<IP-BLOCK-HERE>" #enter the public IP address of the computer you will use to conect to the EC2 instance
    SSHKeyName             = "osm"   #enter the name of the SSH key pair you will use to connect to the EC2 instance
    SatelliteName          = "AQUA"
    SubnetId               = aws_subnet.subnet.id 
    VpcId                  = aws_vpc.vpc.id  
  }

  capabilities = ["CAPABILITY_IAM"]
}

#creating the processor stack
resource "aws_cloudformation_stack" "data_processing" {
  name = "<your-stack-name-here>"
  template_url = "https://aws-gs-blog.s3.us-east-2.amazonaws.com/cfn/ipopp-instance.yml"

  parameters = {
    InstanceType           = "m5.4xlarge"
    IpoppPassword          = "Pl34s3CH4nG3M3" #password for the ipopp user in centOS, must be at least 8 characters in lenght
    S3Bucket               = aws_s3_bucket.bucket.id
    SSHCidrBlock           = "<IP-BLOCK-HERE>" #enter the public IP address of the computer you will use to conect to the EC2 instance
    SSHKeyName             = "osm"   #enter the name of the SSH key pair you will use to connect to the EC2 instance
    SatelliteName          = "AQUA"
    SubnetId               = aws_subnet.subnet.id 
    VpcId                  = aws_vpc.vpc.id  
  }

  capabilities = ["CAPABILITY_IAM"]
}
```

Mission profile: 

Este bloco de código do Terraform permite criar uma pilha do CloudFormation para definir o Perfil de Missão. O Perfil de Missão contém as configurações necessárias para a missão do satélite AQUA, para este stack, foi utilizado um template criado pela equipe da AWS com fins didaticos, este template configura todas as ações necessárias para receber, demodular e processar o sinal RAW do satélite AQUA, salvando-o de volta no bucket s3 ja como dados de nivel L0.



Para configurar este bloco, siga as instruções abaixo:

1. Substitua "<your-stack-name-here>" pelo nome desejado para a pilha. Escolha um nome que seja descritivo e único.
2. Certifique-se de ter acesso à URL do template "aqua-rt-stps.yml" fornecida pela Amazon S3, que contém as definições para o Perfil de Missão.
3. Verifique e ajuste os parâmetros conforme necessário, como:
    - "CreateReceiverInstance": Defina como "false" se você não deseja criar uma instância de receptor.
    - "InstanceType": Escolha o tipo de instância EC2 que atenda aos requisitos de processamento.
    - "SSHCidrBlock": Insira o endereço IP público do computador que você usará para se conectar à instância EC2.
    - "SSHKeyName": Insira o nome do par de chaves SSH que você usará para se conectar à instância EC2.
    - "SatelliteName": Insira o nome do satélite, neste caso, "AQUA".

Após fazer essas alterações, você pode executar o código do Terraform para criar a pilha do CloudFormation e definir o Perfil de Missão para o satélite AQUA.

Será necessário manualmente alterar o parâmetro "CreateReceiverInstance" para true antes do contato com o satélite, o recomendado é fazer isto aproximadamente 15 minutos antes do contato.

Processor Stack:

 Essa pilha contém as configurações necessárias para o processamento dos dados recebidos do satélite AQUA, transformando-os de nivel L0, para nive L1, L2 e L3. 

Para este stack, foi utilizado um template criado pela equipe da AWS com fins didaticos, este template configura todas as ações necessárias para processar os dados até os arquivos finais.

Para configurar este bloco, siga as instruções abaixo:

1. Substitua "<your-stack-name-here>" pelo nome desejado para a pilha. Escolha um nome que seja descritivo e único.
2. Verifique e ajuste os parâmetros conforme necessário, como:
    - "InstanceType": Escolha o tipo de instância EC2 que atenda aos requisitos de processamento.
    - "IpoppPassword": Insira a senha para o usuário "ipopp" no sistema operacional CentOS. A senha deve ter pelo menos 8 caracteres.
    - "SSHCidrBlock": Insira o endereço IP público do computador que você usará para se conectar à instância EC2.
    - "SSHKeyName": Insira o nome do par de chaves SSH que você usará para se conectar à instância EC2.
    - "SatelliteName": Insira o nome do satélite, neste caso, "AQUA".

### vpc.tf

```python
resource "aws_vpc" "vpc" {
  cidr_block = "172.16.0.0/20" #enter the CIDR block you want to use for the VPC
  tags = {
    Name = "<NAME-HERE>"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "<NAME-HERE>"
  }
}

# Create Route Table
resource "aws_route_table" "table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "<NAME-HERE>"
  }
}

#then create a subnet
resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "<CIDR-BLOCK-HERE>" #enter the CIDR block you want to use for the subnet
  availability_zone       = "us-east-1a" #enter the availability zone you want to use for the subnet
  map_public_ip_on_launch = true

  tags = {
    Name = "<NAME-HERE>"
  }
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "router_table" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.table.id
}
```

Este bloco de código do Terraform permite criar uma VPC (Virtual Private Cloud) e uma subnet na AWS. A VPC é uma rede virtual isolada na nuvem da AWS, e a subnet é uma subdivisão dessa rede. Para configurar este bloco, siga as instruções abaixo:

1. No recurso "aws_vpc", substitua "<CIDR-BLOCK-HERE>" pelo bloco CIDR desejado para a VPC. O bloco CIDR define o intervalo de endereços IP que será usado pela VPC.
2. No bloco "tags", substitua "<NAME-HERE>" pelo nome desejado para a VPC. Escolha um nome descritivo e único para identificar a VPC.
3. No recurso "aws_subnet", substitua "<SUBNET-RANGE-HERE>" pelo bloco CIDR desejado para a subnet. O bloco CIDR define o intervalo de endereços IP que será usado pela subnet.
4. No parâmetro "availability_zone", substitua "us-east-1a" pela zona de disponibilidade desejada para a subnet. Certifique-se de escolher uma zona de disponibilidade válida para sua região.
5. No bloco "tags", substitua "<SUBNET-NAME-HERE>" pelo nome desejado para a subnet. Escolha um nome descritivo e único para identificar a subnet.

Após fazer essas alterações, você pode executar o código do Terraform para criar a VPC e a subnet correspondente na AWS. Esses recursos fornecerão a infraestrutura de rede necessária para implantar e gerenciar outros componentes da sua aplicação na nuvem.

### cloud_watch.tf

```python
#creating a simple notification sistem to send out emails with the cloudWatch alarms
locals {
  emails = ["<EMAIL-LIST-HERE>"]
}

resource "aws_sns_topic" "stack_notifications" {
  name   = "<TOPIC-NAME-HERE>"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  count     = length(local.emails)
  topic_arn = aws_sns_topic.stack_notifications.arn
  protocol  = "email"
  endpoint  = local.emails[count.index]
}

#creating a cloudWatch alarm to monitor when something is stored in the S3 bucket
resource "aws_cloudwatch_metric_alarm" "example_alarm" {
  alarm_name          = "<ALARM-NAME-HERE>"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "NumberOfObjectsUploaded"
  namespace           = "AWS/S3"
  period              = "60"
  statistic           = "SampleCount"
  threshold           = "1"
  alarm_description   = "Alarm triggered when objects are uploaded to the S3 bucket."
  alarm_actions       = [aws_sns_topic.stack_notifications.arn]

  dimensions = {
    BucketName = aws_s3_bucket.bucket.id
  }
}

#for every stack we create a cloudWatch alarm to monitor the number of resources in the stack
resource "aws_cloudwatch_metric_alarm" "resource_count_alarm_0" {
  alarm_name          = "<ALARM-NAME-HERE>"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ResourceCount"
  namespace           = "AWS/CloudFormation"
  period              = 60
  statistic           = "Average" 
  threshold           = 12 #change to the number of resources you want to monitor, the yaml script used as a template for the stacks has 31 resources
  alarm_description   = "Monitors the count of resources in the CloudFormation stack"
  alarm_actions       = [aws_sns_topic.stack_notifications.arn]
  dimensions = {
    StackName = aws_cloudformation_stack.mission_profile.id
  }
}

resource "aws_cloudwatch_metric_alarm" "resource_count_alarm_1" {
  alarm_name          = "<ALARM-NAME-HERE>"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ResourceCount"
  namespace           = "AWS/CloudFormation"
  period              = 60
  statistic           = "Average"
  threshold           = 5 #change to the number of resources you want to monitor
  alarm_description   = "Monitors the count of resources in the CloudFormation stack"
  alarm_actions       = [aws_sns_topic.stack_notifications.arn]
  dimensions = {
    StackName = aws_cloudformation_stack.data_processing.id
  }
}

#CPU utilization alarms

#too low
resource "aws_cloudwatch_metric_alarm" "cpu_utilization_alarm_too_low_0" {
  alarm_name          = "<ALARM-NAME-HERE>"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 20
  alarm_description   = "Triggered when CPU utilization is below 20%"
  alarm_actions       = [aws_sns_topic.stack_notifications.arn]  
  dimensions = {
    InstanceId = aws_cloudformation_stack.mission_profile.id
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_alarm_too_low_1" {
  alarm_name          = "<ALARM-NAME-HERE>"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 20
  alarm_description   = "Triggered when CPU utilization is below 20%"
  alarm_actions       = [aws_sns_topic.stack_notifications.arn]  

  dimensions = {
    InstanceId = aws_cloudformation_stack.data_processing.id
  }
}

#too high
resource "aws_cloudwatch_metric_alarm" "cpu_utilization_alarm_too_high_0" {
  alarm_name          = "<ALARM-NAME-HERE>"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 90
  alarm_description   = "Triggered when CPU utilization is above 90%"
  alarm_actions       = [aws_sns_topic.stack_notifications.arn]  

  dimensions = {
    InstanceId = aws_cloudformation_stack.mission_profile.id
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_alarm_too_high_1" {
  alarm_name          = "<ALARM-NAME-HERE>"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 90
  alarm_description   = "Triggered when CPU utilization is above 90%"
  alarm_actions       = [aws_sns_topic.stack_notifications.arn]  

  dimensions = {
    InstanceId = aws_cloudformation_stack.data_processing.id
  }
}

#Memory utilization alarms
resource "aws_cloudwatch_metric_alarm" "memory_utilization_alarm_0" {
  alarm_name          = "<ALARM-NAME-HERE>"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "MemoryUtilization"
  namespace           = "System/Linux"
  period              = 300
  statistic           = "Average"
  threshold           = 90
  alarm_description   = "Triggered when memory utilization is above 90%"
  alarm_actions       = [aws_sns_topic.stack_notifications.arn]   
  dimensions = {
    InstanceId = aws_cloudformation_stack.mission_profile.id  
  }
}

resource "aws_cloudwatch_metric_alarm" "memory_utilization_alarm_1" {
  alarm_name          = "<ALARM-NAME-HERE>"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "MemoryUtilization"
  namespace           = "System/Linux"
  period              = 300
  statistic           = "Average"
  threshold           = 90
  alarm_description   = "Triggered when memory utilization is above 90%"
  alarm_actions       = [aws_sns_topic.stack_notifications.arn]   
  dimensions = {
    InstanceId = aws_cloudformation_stack.data_processing.id  
  }
}
```

Este bloco de código do Terraform permite criar um sistema de notificação e alarmes usando o serviço CloudWatch da AWS. Ele inclui a criação de um tópico SNS (Simple Notification Service) para envio de emails e a configuração de vários alarmes baseados em métricas. Siga as instruções abaixo para configurar esse sistema:

1. No recurso "aws_sns_topic", substitua "<TOPIC-NAME-HERE>" pelo nome desejado para o tópico SNS. Escolha um nome descritivo e único para identificar o tópico.
2. No recurso "aws_sns_topic_subscription", substitua "<EMAIL-LIST-HERE>" por uma lista de endereços de email para receber as notificações por email. Certifique-se de que os endereços de email sejam válidos e estejam dentro de aspas duplas.
3. No recurso "aws_cloudwatch_metric_alarm", substitua "<ALARM-NAME-HERE>" pelo nome desejado para o alarme. Escolha um nome descritivo para identificar o alarme.
4. Ajuste os parâmetros específicos de cada alarme de acordo com suas necessidades. Por exemplo, você pode personalizar as métricas, os períodos de avaliação, os operadores de comparação, os limiares e as dimensões.

Repita o último recurso "aws_cloudwatch_metric_alarm" conforme necessário para criar mais alarmes com base nas métricas desejadas. Certifique-se de ajustar os nomes dos alarmes, os valores dos limiares e as dimensões de acordo com suas necessidades.

Após fazer essas alterações, você pode executar o código do Terraform para criar o sistema de notificação e alarmes com o CloudWatch na AWS. Isso permitirá que você monitore várias métricas e seja notificado por email quando os alarmes forem acionados, com base nas configurações definidas.

Os alarmes definidos foram:

1. **aws_cloudwatch_metric_alarm.example_alarm**: Este alarme monitora a quantidade de objetos carregados no bucket S3. Ele é acionado quando o número de objetos carregados é maior que o limiar definido, neste caso, 1. A intenção é alertar quando ocorrerem uploads de objetos no bucket S3.
2. **aws_cloudwatch_metric_alarm.resource_count_alarm_0**: Este alarme monitora a contagem de recursos no stack de CloudFormation chamado "mission_profile". Ele é acionado quando o número de recursos excede o limiar definido, neste caso, 12. O objetivo é monitorar a quantidade de recursos presentes no stack e alertar caso haja um aumento inesperado.
3. **aws_cloudwatch_metric_alarm.resource_count_alarm_1**: Similar ao alarme anterior, este alarme monitora a contagem de recursos no stack de CloudFormation chamado "data_processing". O limiar definido é 5, portanto, ele alertará se o número de recursos ultrapassar esse valor.
4. **aws_cloudwatch_metric_alarm.cpu_utilization_alarm_too_low_0**: Este alarme monitora a utilização da CPU do stack de CloudFormation "mission_profile". Ele é acionado quando a utilização da CPU fica abaixo do limiar definido, neste caso, 20%. O objetivo é detectar casos em que a CPU esteja operando em um nível muito baixo.
5. **aws_cloudwatch_metric_alarm.cpu_utilization_alarm_too_low_1**: Similar ao alarme anterior, este alarme monitora a utilização da CPU do stack de CloudFormation "data_processing".
6. **aws_cloudwatch_metric_alarm.cpu_utilization_alarm_too_high_0**: Este alarme monitora a utilização da CPU do stack de CloudFormation "mission_profile". Ele é acionado quando a utilização da CPU ultrapassa o limiar definido, neste caso, 90%. O objetivo é identificar casos em que a CPU esteja operando em um nível muito alto.
7. **aws_cloudwatch_metric_alarm.cpu_utilization_alarm_too_high_1**: Similar ao alarme anterior, este alarme monitora a utilização da CPU do stack de CloudFormation "data_processing".
8. **aws_cloudwatch_metric_alarm.memory_utilization_alarm_0**: Este alarme monitora a utilização da memória do stack de CloudFormation "mission_profile". Ele é acionado quando a utilização da memória ultrapassa o limiar definido, neste caso, 90%. O objetivo é detectar casos em que a memória esteja operando em um nível muito alto.
9. **aws_cloudwatch_metric_alarm.memory_utilization_alarm_1**: Similar ao alarme anterior, este alarme monitora a utilização da memória do stack de CloudFormation "data_processing".

Esses alarmes permitem monitorar diversos aspectos dos stacks de CloudFormation e receber notificações por email quando condições específicas forem atendidas. As configurações, como nomes, limiares e dimensões, podem ser ajustadas de acordo com as necessidades e requisitos específicos do ambiente.