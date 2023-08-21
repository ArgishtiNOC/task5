resource "aws_instance" "task_4"{
  
    ami = "${var.ami}"
    instance_type = "${var.instance_type}"
    subnet_id  =  var.subnet_id
    iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
    vpc_security_group_ids = [aws_security_group.task4.id]
    associate_public_ip_address = true
    user_data = <<-EOF
    #!/bin/bash
    docker pull public.ecr.aws/z4r1d8r6/task4
    docker run -p 80:3000 public.ecr.aws/z4r1d8r6/task4
    EOF


}

resource "aws_security_group" "task4" {
    name = "task4"
    vpc_id = var.security_group_vpc_id
    dynamic "ingress" {
      for_each = ["22", "80", "3000"]  
      content{
        from_port = ingress.value
        to_port   = ingress.value
        protocol  = "tcp"
        cidr_blocks = ["0.0.0.0/0"] 
      }
    }
    
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

}


resource "aws_iam_role" "task4_role" {
  name = "task4"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}



resource "aws_iam_role_policy_attachment" "task4_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.task4_role.name
}

resource "aws_iam_role_policy_attachment" "task4_1_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.task4_role.name
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "profile"
  role = aws_iam_role.task4_role.name
}

