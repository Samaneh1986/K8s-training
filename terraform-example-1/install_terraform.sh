curl -s https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo echo "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main" > /etc/apt/sources.list.d/terraform.list
sudo apt update
sudo apt install terraform
terraform -version
