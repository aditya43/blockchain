#!/bin/sh

# install git
install_git(){
    sudo apt install git -y
}
# install curl
install_curl(){
    sudo apt install curl -y
}

# install docker
install_docker(){
    sudo apt install \
        apt-transport-https \
        ca-certificates \
        gnupg-agent \
        software-properties-common -y
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo apt-key fingerprint 0EBFCD88
    sudo add-apt-repository \
        "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) \
        stable"
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose -y
    sudo usermod -aG docker $USER
    newgrp docker
}
# install golang
install_golang(){
    curl -o "go.tar.gz" https://storage.googleapis.com/golang/go1.17.2.linux-amd64.tar.gz
    sudo chmod +x go.tar.gz
    sudo tar -C /home/vagrant/mount -xzf "go.tar.gz"
}
# install node
install_node(){
    curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
    sudo apt install nodejs -y
    npm config rm proxy
    npm config rm https-proxy
}

# install zsh
install_zsh(){
    sudo apt install zsh -y
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

# install zsh plugins and configure theme
configure_zsh() {
    # install zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    # install syntax-highlighting
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    # install zsh-completions
    git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions
    # backup current .zshrc file
    mv -n ~/.zshrc ~/.zshrc-backup

    touch "$HOME/.zshrc"
    {
        echo 'export ZSH="/home/vagrant/.oh-my-zsh"'
        echo 'ZSH_THEME="agnoster"'
        echo "plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)"
        echo "autoload -U compinit && compinit"
        echo "source ~/.oh-my-zsh/oh-my-zsh.sh"
        echo "prompt_context() {}"
    } >> "$HOME/.zshrc"

    source ~/.zshrc
}


install_git
install_curl
install_docker
install_golang
install_node
install_zsh
configure_zsh

sudo touch "$HOME/.bashrc"
{
    echo "export PATH=$PATH:/home/vagrant/mount/go/bin"
    echo 'export GOPATH="/home/vagrant/mount/chaincode"'
    echo "zsh"
} >> "$HOME/.bashrc"