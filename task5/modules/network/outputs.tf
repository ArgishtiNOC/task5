output "vpc_id"{
    value = aws_vpc.task4.id
}

output "public_subnet_1_id"{
    value = aws_subnet.task4-public-1.id
}

output "public_subnet_2_id"{
    value = aws_subnet.task4-public-2.id
}

