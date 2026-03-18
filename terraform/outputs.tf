# Define outputs to display
# Output the value of the public IP address of the web server
output "web_server_public_ip" {
  value = aws_eip.one.public_ip
}