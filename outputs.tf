output "private_key_pem" {
  value     = tls_private_key.pki.private_key_pem
  sensitive = true
}

output "rdp-pw" {
  value = random_string.password.result
}

/* Outputs for AMI IDs */
# output "current_win22d" {
#   value = data.aws_ami.pssec-w22d.id
# }

# output "current_u22c" {
#   value = data.aws_ami.pssec-u22c.id
# }

output "current_u22d" {
  value = data.aws_ami.pssec-u22d.id
}

output "exec_time" {
  value = timestamp()
}
