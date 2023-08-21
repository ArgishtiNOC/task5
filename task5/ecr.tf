resource "aws_ecrpublic_repository" "ecr_erpo" {
  repository_name = "task4"

  catalog_data {
    about_text        = "About Text"
    description       = "Description"
    operating_systems = ["Linux"]
    
  }

  tags = {
    env = "production"
  }
}

output "ecr" {

  value = aws_ecrpublic_repository.ecr_erpo.arn
}

output "ecr1" {

  value = aws_ecrpublic_repository.ecr_erpo.registry_id
}

output "ecr2" {

  value = aws_ecrpublic_repository.ecr_erpo.id
}

output "ecr3" {

  value = aws_ecrpublic_repository.ecr_erpo.repository_uri
}


resource "null_resource" "docker_build"{
    triggers = {
        repo_url = aws_ecrpublic_repository.ecr_erpo.repository_uri
    }
    provisioner "local-exec" {
        command = "(aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws/z4r1d8r6)"

    }

    provisioner "local-exec" {
        command = "docker build -t ${aws_ecrpublic_repository.ecr_erpo.repository_name}:latest /home/user/brainscale-simple-app"

    }

    provisioner "local-exec" {
        command = "docker tag ${aws_ecrpublic_repository.ecr_erpo.repository_name}:latest ${aws_ecrpublic_repository.ecr_erpo.repository_uri}:latest "

    }
    
    provisioner "local-exec" {
        command = "docker push  ${aws_ecrpublic_repository.ecr_erpo.repository_uri}:latest"

    }

}