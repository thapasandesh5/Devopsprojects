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

resource "aws_instance" "tomcatt_server" {
  ami             = "ami-0cff7528ff583bf9a"
  instance_type   = "t2.micro"
  key_name = "terraform"
  security_groups = ["terraform"]
  user_data = file("tomcatt.sh")

  tags = {
    Name = "tomcattt_server-terraform"
  }
}
