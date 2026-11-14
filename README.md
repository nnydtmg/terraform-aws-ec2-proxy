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



## セキュリティに関する注意

- 学習用のサンプルです。本番で利用する場合は、セキュリティグループの許可範囲などを要件に合わせて見直してください。
- EC2 インスタンスは IMDSv2 を必須にし、ルートボリュームを暗号化しています。
