#To print out public ip
output  "maven_ip" {
    value = aws_instance.maven_server.public_ip
}

output "prod_ip" {
    value = aws_instance.prod_server.public_ip
  
}