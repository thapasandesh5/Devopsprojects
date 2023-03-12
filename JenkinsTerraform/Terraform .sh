#!/bin/bash
sudo yum install ec2-instance-connect
sudo yum update -y
sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum upgrade
sudo amazon-linux-extras install java-openjdk11 -y
sudo yum install jenkins -y
sudo systemctl enable jenkins
sudo systemctl start jenkins
echo status jenkins
sudo systemctl status jenkins
sudo yum install git -y


resource "aws_instance" "jenkins_server" {
  ami             = "ami-0cff7528ff583bf9a"
  instance_type   = "t2.micro"
  key_name = "terraform"
  security_groups = ["terraform"]
  user_data = file("jenkin.sh")

  tags = {
    Name = "Jenkins_server-terraform"
  }
