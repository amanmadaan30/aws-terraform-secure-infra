/*

    1. rds tf resource
    2. security group
        - 3306 
            - security-grp => tf-ec2-sg  (so that mysql inside rds instance can communicate with ec2 instance through sec grp)
            - cidr_block (to allow particular ip addresses to allow to connect to db/rds instance) ["local ip address"]

    3. outputs
*/

resource "aws_db_instance" "tf_rds_instance" {
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  identifier             = "nodejs-rds-mysql"
  db_name                = "aman_demo"
  username               = "aman"
  password               = var.db_password
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = false
  publicly_accessible    = false
  storage_encrypted      = true
  vpc_security_group_ids = [aws_security_group.tf_rds_sg.id]
}

resource "aws_security_group" "tf_rds_sg" {
  name        = "nodejs_rds_sg"
  vpc_id      = var.vpc_id # associate own vpc with security group
  description = "Allow MySQL traffic"

  ingress {
    description     = "database traffic port"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    cidr_blocks     = [var.admin_cidr]                  #local ip address
    security_groups = [aws_security_group.tf-ec2-sg.id] # associate ec2 sg with rds sg so that they can connect to each other.
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


}
# outputs
output "rds_endpoint" {
  value = aws_db_instance.tf_rds_instance.endpoint
}

output "rds_dbname" {
  value = aws_db_instance.tf_rds_instance.db_name
}
