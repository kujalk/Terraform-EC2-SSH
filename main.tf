/*
Generate Keypair dynamically store it in the file
Create EC2 instance with the Key pair generate
*/

resource "tls_private_key" "ssh-key" {
  algorithm = "RSA"
  rsa_bits  = 2048

  provisioner "local-exec" {
    command     = <<EOT
    '${tls_private_key.ssh-key.private_key_pem}' | % {$_ -replace "`r", ""} | Set-Content -NoNewline ./'${var.keyname}.pem' -Force
    EOT
    interpreter = ["PowerShell", "-Command"]
  }
}

resource "aws_key_pair" "generated-key" {
  key_name   = var.keyname
  public_key = tls_private_key.ssh-key.public_key_openssh
}

resource "aws_instance" "Server" {
  ami           = var.amiid
  instance_type = var.ec2type
  key_name      = aws_key_pair.generated-key.key_name

  tags = {
    Name = var.ec2name
  }
}
