/*
1. ec2 instance resource
2. new security group
    - 22 (ssh)
    - 443 (https)
    - 3000 (nodejs application) // ip:3000
*/

resource "aws_instance" "tf-ec2-instance" {
  ami                         = "ami-0a59248a6294cece2" # ubuntu instance
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  key_name                    = "terraform-ec2"
  vpc_security_group_ids      = [aws_security_group.tf-ec2-sg.id]
  depends_on                  = [aws_s3_object.tf-s3-object]

  user_data                   = <<-EOF
  #!/bin/bash
  
  #Git clone your repo
  git clone https://github.com/amanmadaan30/aws-terraform-secure-infra.git

  # Install Node.js 
  sudo apt update -y
  sudo apt install -y nodejs npm

  

  # Edit env variables
  echo "DB_HOST=${aws_db_instance.tf_rds_instance.endpoint}" | sudo tee .env
  echo "DB_USER=${aws_db_instance.tf_rds_instance.username}" | sudo tee -a .env
  echo "DB_PASS=${aws_db_instance.tf_rds_instance.password}" | sudo tee -a .env
  echo "DB_NAME=${aws_db_instance.tf_rds_instance.db_name}" | sudo tee -a .env
  echo "TABLE_NAME=users" | sudo tee -a .env
  echo "PORT=3000" | sudo tee -a .env

  # Install dependencies & start server
  npm install
  EOF 
  user_data_replace_on_change = true
  tags = {
    Name = "Node js server"
  }
}

resource "aws_security_group" "tf-ec2-sg" {
  name        = "nodejs-server-sg"
  vpc_id      = "vpc-0eef14b2c7a02fb58" # associate own vpc with security group
  description = "Allow SSH, HTTPS, and app traffic"

  ingress {
    description = "SSH from admin IP only" # to enhance security
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr] #open to internet, earlier "0.0.0.0/0"
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Node App"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nodejs-sg"
  }
}

#output operation so that we do ssh into system as an output of this operation

output "ec2_public_ip" {
  value = "ssh -i ~/.ssh/terraform-ec2.pem ubuntu@${aws_instance.tf-ec2-instance.public_ip}"
}
