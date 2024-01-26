provider "aws" {
  region = "us-east-2"
}

resource "aws_s3_bucket" "pellizzi_bucket_flask" {
  bucket = "pellizzi-914156456046-bucket" 

  tags = {
    Name        = "Pellizzi Bucket"
    Environment = "Invest Model"
  }

  provisioner "local-exec" {
    command = "${path.module}/upload_to_s3.sh"
  }

  # Para destruir um S3, é preciso antes excluir os arquivos do S3. 
  # rm é de remove e (--recursive) é para limpar de maneira recursiva o conteúdo do Bucket S3.  
  # O command remove o conteúdo do S3 primeiro, e ai o terraform faz o trabalho dele com o destroy.

  provisioner "local-exec" {
    when    = destroy
    command = "aws s3 rm s3://pellizzi-914156456046-bucket --recursive"
  }
}

resource "aws_instance" "pellizzi_ml_api" {

  ami = "ami-0a0d9cf81c479446a" 

  instance_type = "t2.micro"

  iam_instance_profile = aws_iam_instance_profile.ec2_s3_profile.name

  vpc_security_group_ids = [aws_security_group.pellizzi_ml_api_sg.id]

  # Script de inicialização
  user_data = <<-EOF
                #!/bin/bash
                sudo yum update -y
                sudo yum install -y python3 python3-pip awscli
                sudo pip3 install flask joblib scikit-learn numpy scipy gunicorn
                sudo mkdir /pellizzi_ml_app
                sudo aws s3 sync s3://pellizzi-914156456046-bucket /pellizzi_ml_app
                cd /pellizzi_ml_app
                nohup gunicorn -w 4 -b 0.0.0.0:5000 app:app &
              EOF


  tags = {
    Name = "PELLIZZIFlaskApp"
  }
}

resource "aws_security_group" "pellizzi_ml_api_sg" {
  
  name        = "pellizzi_ml_api_sg"
  
  description = "Security Group for Flask App in EC2"

  # Essa é aporta padrão do http.

  ingress {
    description = "Inbound Rule 1"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 500 é a porta que vai rodar a aplicação. 

  ingress {
    description = "Inbound Rule 2"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # A porta 22 é do ssh. Vamos acessar o terminar pelo navegador e para isso, precisa estar com a porta 22 aberta.

  ingress {
    description = "Inbound Rule 3"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # A regra de saíde é qualquer porta com o protocolo tcp para qualquer endereço na internet.

  egress {
    description = "Outbound Rule"
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "ec2_s3_access_role" {
  
  name = "ec2_s3_access_role"

  # 'Version = "2012-10-17"' é padrão da política de segurança da AWS.

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "s3_access_policy" {
  
  name = "s3_access_policy"
  
  role = aws_iam_role.ec2_s3_access_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Effect = "Allow",
        Resource = [
          "${aws_s3_bucket.pellizzi_bucket_flask.arn}/*",
          "${aws_s3_bucket.pellizzi_bucket_flask.arn}"
        ]
      },
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_s3_profile" {
  name = "ec2_s3_profile"
  role = aws_iam_role.ec2_s3_access_role.name
}


