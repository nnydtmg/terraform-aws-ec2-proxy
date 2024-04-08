# terraform-aws-ec2-proxy
AWS上でSquidを用いて透過的プロキシを構築する記事の参考環境

![](https://github.com/nnydtmg/zenn-articles/blob/main/images/aws-squid-proxy/01-architecture.png)

## Install
https://developer.hashicorp.com/terraform/install

```bash
sudo yum install -y yum-utils shadow-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform
```

## Apply

```bash
git clone https://github.com/nnydtmg/terraform-aws-ec2-proxy.git
cd terraform-aws-ec2-proxy
terraform init
terraform apply
```


