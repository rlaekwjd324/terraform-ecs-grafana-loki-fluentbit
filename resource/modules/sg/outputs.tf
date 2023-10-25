output "private_ec2_sg_id" {
  value = aws_security_group.terraform-test-private-ec2.id
}
output "public_ec2_sg_id" {
  value = aws_security_group.terraform-test-public-ec2.id
}
output "alb_sg_id" {
  value = aws_security_group.terraform-test-alb.id
}
output "rds_sg_id" {
  value = aws_security_group.terraform-test-rds-security-group.id
}