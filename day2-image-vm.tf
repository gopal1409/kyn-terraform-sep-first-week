##create a new file image.tf copy line 2 till 27
  data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

output "ubuntu_ami_id" {
  value = data.aws_ami.ubuntu.id
}

##lets create an shell script which will install apache server. app.sh copy line 30 till 36
#!/bin/bash
sudo apt-get update -y
sudo apt install -y apache2
sudo systemctl start apache2
sudo systemctl enable apache2
sudo chmod -R 777 /var/www/html
sudo echo "Welcome to the site $(hostname)" > /var/www/html/index.html

  ##finally lets create the vm create a file vm.tf
  resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id #this is the ami id for ubuntu 20.04
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web.id] #this is the security group id which we created earlier
  associate_public_ip_address = true #this is to associate the public ip address with the instance
  subnet_id     = aws_subnet.projecty-subnet["subnet1"].id #this is the subnet id which we created earlier
  key_name      = "gopal" #this is the key pair name which we created earlier
  user_data     = file("${path.module}/app.sh") #this is the user data script which we created earlier
#this path.module is an meta argument in terraform which is used for looking for a file in current directory
  tags = local.common_tags
}

output "web_instance_id" {
  description = "The ID of the web instance"
  value       = aws_instance.web.id
}

output "web_instance_public_ip" {
  description = "The public IP address of the web instance"
  value       = aws_instance.web.public_ip
}
