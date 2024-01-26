# Modelo de Previsão de Investimento na Nuvem AWS

Este projeto implementa uma solução totalmente automatizada utilizando Infrastructure as Code (IaC) com Terraform, Docker e serviços da AWS. A aplicação consiste em um servidor web Flask que se comunica com uma API contendo um modelo de machine learning treinado para prever se um cliente fará ou não um novo investimento com base em atributos específicos.

## Configuração do Ambiente

Certifique-se de ter o Docker, o Terraform e as credenciais da AWS configuradas antes de iniciar.

### Criar a Imagem Docker

```bash
docker build -t pellizzi-terraform-image:invest_model .
```

### Criar o Container Docker na AWS

```bash
docker run -dit --name pellizzi-invest_model -v /caminho/local/do/projeto:/iac pellizzi-terraform-image:invest_model /bin/bash
```

## Arquitetura da Nuvem

A arquitetura na nuvem AWS inclui:

- **Bucket S3**: Armazena os arquivos necessários para a aplicação.
- **Instância EC2**: Executa o servidor web Flask e a aplicação de machine learning.

## Estrutura do Projeto

- **`Dockerfile`**: Configura a imagem Docker com as dependências necessárias.
- **`main.tf`**: IaC com Terraform para provisionar recursos na AWS.
- **`outputs.tf`**: Define as saídas do Terraform, incluindo o DNS público da instância EC2.
- **`upload_to_s3.sh`**: Script para sincronizar o conteúdo local com o bucket S3.
- **`app.py`**: Aplicação Flask que se comunica com a API de machine learning.
- **`modelo.py`**: Script Python que cria, treina e salva o modelo de machine learning.
- **`index.html`**: Página HTML para a interface do usuário.

## Como Usar

1. **Iniciar a Aplicação Flask na Nuvem**:

   ```bash
   python app.py
   ```

   Acesse a aplicação através do navegador no endereço [http://DNS_PUBLICO_DA_INSTANCIA:5000](http://DNS_PUBLICO_DA_INSTANCIA:5000).

2. **Realizar Previsões**:

   Preencha os valores de investimento na interface e clique em "Prever" para obter a previsão.

## Observações

- Certifique-se de ter as credenciais da AWS configuradas localmente.
- Acesse o console AWS para monitorar os recursos provisionados.

Este projeto demonstra a automação completa da infraestrutura e aplicação na nuvem AWS, proporcionando escalabilidade e eficiência operacional.
```
