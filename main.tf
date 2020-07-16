

resource "aws_security_group" "my_security_group" {
  name        = "taskSG2"
  description = "Allow TLS inbound traffic"
  
  
  ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "6"
      cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
      from_port   = 22
      to_port    = 22
      protocol    = "6"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "taskSG2"
  }
}


// Launching my EC2 instance

resource "aws_instance" "shndweb" {
  ami           = "ami-0447a12f28fddb066"
  instance_type = "t2.micro"
  key_name = "Mainkey"
  security_groups = [ aws_security_group.my_security_group.id ]
  subnet_id = "subnet-44073d2c"

  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("D:/awscloud/Mainkey.pem")
    host     = aws_instance.shndweb.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd  php git -y",
      "sudo systemctl restart httpd",
      "sudo systemctl enable httpd",
    
    ]
  }

  tags = {
    Name = "shndos1"
  }

}

// creating EFS
resource "aws_efs_file_system" "shndefs" {
  creation_token = "shndefsfile"

  tags = {
    Name = "efsFileSystem"
  }
}

//mount
resource "aws_efs_mount_target" "nullremote3" {
  file_system_id  = aws_efs_file_system.shndefs.id
  subnet_id = "subnet-44073d2c"
  security_groups = [aws_security_group.my_security_group.id]
}

// Configure the external volume
// Configuring the external volume
resource "null_resource" "setupVol" {
  depends_on = [
    aws_efs_mount_target.nullremote3,
  ]


connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("D:/awscloud/Mainkey.pem")
    host     = aws_instance.shndweb.public_ip
  }

provisioner "remote-exec"{
   
       inline = [
         
          "sudo yum install httpd php git -y",
	        "sudo systemctl start httpd",
	        "sudo systemctl enable httpd",
          "sudo mkfs.ext4  /dev/xvdf",
          "sudo rm -rf /var/www/html/*",
          "sudo mount  /dev/xvdf  /var/www/html",
          "sudo git clone https://github.com/Harsh-Gupta9897/task2.git /html_repo",
	        "sudo cp -r /html_repo/* /var/www/html",
	        "sudo rm -rf /html_repo"
         ]

    }
}




resource "null_resource" "nulllocal2"  {
	provisioner "local-exec" {
	    command = "echo  ${aws_instance.shndweb.public_ip} > publicip.txt"
  	}
}






output "myos_ip" {
  value = aws_instance.shndweb.public_ip
}




