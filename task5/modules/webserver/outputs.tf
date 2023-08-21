output "ec2_public_ip"{
  value = aws_instance.task_4.public_ip
}

output "security_group_id"{
  value = aws_security_group.task4.id
}

output "instance_id"{
  value = aws_instance.task_4.id
}
