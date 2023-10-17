output "vpc_id" {
  value = aws_vpc.terraform-test-vpc.id
}
output "public_subnet_1_id" {
  value = aws_subnet.terraform-test-public-subnet-1.id
}
output "public_subnet_2_id" {
  value = aws_subnet.terraform-test-public-subnet-2.id
}
output "private_subnet_3_id" {
  value = aws_subnet.terraform-test-private-subnet-3.id
}
output "public_subnet_5_id" {
  value = aws_subnet.terraform-test-public-subnet-5.id
}
output "public_subnet_6_id" {
  value = aws_subnet.terraform-test-public-subnet-6.id
}