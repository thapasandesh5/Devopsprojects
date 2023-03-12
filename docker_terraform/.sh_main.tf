resource "aws_instance" "docker_server" {
  ami             = "ami-0cff7528ff583bf9a"
  instance_type   = "t2.micro"
  key_name = "terraform"
  security_groups = ["terraform"]
  user_data = file("dockerr.sh")

  tags = {
    Name = "docker_server-terraform"
  }
}

#!/bin/bash

sudo yum update -y
sudo amazon-linux-extras install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo systemctl enable docker
