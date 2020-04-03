# quorum-network
Quorum Net files

This is the content of fromscratch file. Use this files and folders which are based in the deployment of Quorum using Tessera. 
Below you may find some usefull information regarding the Quorum platform and its components. Also you will find a step by step guide for the deployment of a Quorum network. The files and folders contained in this project are the result of a deployment that followed this guide.

What is Quorum? 

Quorum is an Ethereum-based distributed ledger protocol that has been developed to provide industries such as finance, supply chain, retail, real estate, etc. with a permissioned implementation of Ethereum that supports transaction and contract privacy. 

Quorum includes a minimalistic fork of the Go Ethereum client (a.k.a geth), and as such, leverages the work that the Ethereum developer community has undertaken. 

The primary features of Quorum, and therefore extensions over public Ethereum, are: 

-Transaction and contract privacy 

-Multiple voting-based consensus mechanisms 

-Network/Peer permissions management 

-Higher performance 

Quorum currently includes the following components: 

-Quorum Node (modified Geth Client) 

-Privacy Manager (Constellation/Tessera) 

  -Transaction Manager 

  -Enclave 

Constellation & Tessera 

Constellation and Tessera are Haskell and Java implementations of a general-purpose system for submitting information in a secure way. They are comparable to a network of MTA (Message Transfer Agents) where messages are encrypted with PGP. It is not blockchain-specific, and are potentially applicable in many other types of applications where you want individually-sealed message exchange within a network of counterparties. The Constellation and Tessera modules consist of two sub-modules: 

-The Node (which is used for Quorum’s default implementation of a PrivateTransactionManager) 

-The Enclave 

-Transaction Manager 

Quorum’s Transaction Manager is responsible for Transaction privacy. It stores and allows access to encrypted transaction data, exchanges encrypted payloads with other participant’s Transaction Managers but does not have access to any sensitive private keys. It utilizes the Enclave for cryptographic functionality (although the Enclave can optionally be hosted by the Transaction Manager itself.) 

The Transaction Manager is restful/stateless and can be load balanced easily. 

The Enclave 

Distributed Ledger protocols typically leverage cryptographic techniques for transaction authenticity, participant authentication, and historical data preservation (i.e. through a chain of cryptographically hashed data.) In order to achieve a separation of concerns, as well as to provide performance improvements through parallelization of certain crypto-operations, much of the cryptographic work including symmetric key generation and data encryption/decryption is delegated to the Enclave. 

The Enclave works hand in hand with the Transaction Manager to strengthen privacy by managing the encryption/decryption in an isolated way. It holds private keys and is essentially a “virtual HSM” isolated from other components. 

Setup of a Quorum testbed using Raft consensus 

There are two different ways to setup a fully functional Quorum blockchain. The easiest way is to use quorum examples where the development of the network is done in a fully automated manner. The most popular example is the 7nodes where a VM is created using vagrant (requires the existence of Virtual Box program). Within this VM 7 fully functional nodes are deployed and they form the Quorum network. For more information regarding the setup of 7nodes example please refer here. 

However in this documentation we will present a step by step deployment, where we create a network from scratch. The goal of this process is to setup a Quorum network consisted from at least two nodes, where each node is hosted in a VM. These VMs will communicate over the internet and are members of the Quorum. This guide includes every single step from the moment we access the vanilla VM instance to the moment we deploy a Smart Contract. The characteristics of each VM are as follows: 

OS: Ubuntu Server 16.04 LTS 

CPU: 2vCPUs 

RAM: 4GB 

Storage: 30GB 

IP: 1 Public IP 

Firewall status: OFF 

Setup the first VM 

  Access to VMs: The access to the VMs should be made by using the public key for security reasons. When we configure the access using the public key we should disable the access using password. 

ssh-copy-id <username>@<domain or IP> : Copy your public key to the VM 

sudo nano /etc/ssh/sshd_config : Access the configuration file and change Password authentication to no. 

When you are in your VM enable your Ubuntu firewall:  

sudo ufw enable : Enable firewall 

sudo ufw allow 22 : Allow port 22 for ssh 

sudo ufw allow 35570 : Allow this port for Quorum 

sudo ufw allow 50000 : Allow this port for Quorum 

sudo ufw allow 21000 : Allow this port for Quorum 

sudo ufw allow 9001 : Allow this port for Tessera 

sudo ufw allow 9003 : Allow this port for Tessera 

sudo ufw allow 9081 : Allow this port for Tessera 

sudo ufw reload : Reload firewall 

Then edit the source list to use the global: 

sudo nano /etc/apt/sources.list : Edit this file and replace every gr. or us. to empty space.  

Then proceed to the installation of several packages (Ethereum, docker) as it is displayed below: 

############# Basic packets ########################### 

sudo apt-get install -y software-properties-common 

sudo add-apt-repository -y ppa:ethereum/ethereum 

sudo apt-get update 

sudo apt-get -y install ethereum 

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - 

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" 

sudo apt-get update 

sudo apt-get install -y docker-ce 

sudo usermod -a -G docker $USER 

sudo reboot 

######### Docker images GO Geth env ################ 

docker pull quorumengineering/quorum 

docker pull quorumengineering/tessera 

docker pull quorumengineering/constellation 

sudo apt-get update 

sudo apt-get -y upgrade 

wget https://dl.google.com/go/go1.12.7.linux-amd64.tar.gz 

sudo tar -xvf go1.12.7.linux-amd64.tar.gz 

sudo mv go /usr/local 

export GOROOT=/usr/local/go 

export GOPATH=$HOME/Projects/Proj1 

export PATH=$GOPATH/bin:$GOROOT/bin:$PATH 

go version 

go env 

git clone https://github.com/jpmorganchase/quorum.git 

sudo apt-get install -y make 

sudo apt-get install -y build-essential 

cd quorum  

make all   

##################### Add at the end of ~/.bashrc the following ############ 

export GOROOT=/usr/local/go 

export GOPATH=$HOME/Projects/Proj1 

export PATH=$GOPATH/bin:$GOROOT/bin:$PATH 

export PATH=/home/user/quorum/build/bin:$PATH 

####################### Create the network ######################### 

mkdir fromscratch 

cd fromscratch  

mkdir new-node-1 

geth --datadir new-node-1 account new 

ls new-node-1/keystore 

nano genesis.json 

{ 

  "alloc": { 

    "0x<Replace with the account id you created above>": { 

      "balance": "1000000000000000000000000000" 

    } 

}, 

 "coinbase": "0x0000000000000000000000000000000000000000", 

 "config": { 

   "homesteadBlock": 0, 

   "byzantiumBlock": 0, 

   "constantinopleBlock": 0, 

   "chainId": 10, 

   "eip150Block": 0, 

   "eip155Block": 0, 

   "eip150Hash": "0x0000000000000000000000000000000000000000000000000000000000000000", 

   "eip158Block": 0, 

   "maxCodeSize": 35, 

   "maxCodeSizeChangeBlock" : 0, 

   "isQuorum": true 

 }, 

 "difficulty": "0x0", 

 "extraData": "0x0000000000000000000000000000000000000000000000000000000000000000", 

 "gasLimit": "0xE0000000", 

 "mixhash": "0x00000000000000000000000000000000000000647572616c65787365646c6578", 

 "nonce": "0x0", 

 "parentHash": "0x0000000000000000000000000000000000000000000000000000000000000000", 

 "timestamp": "0x00" 

}    

 

 

bootnode --genkey=nodekey 

cp nodekey new-node-1/ 

bootnode --nodekey=new-node-1/nodekey --writeaddress > new-node-1/enode 

cat new-node-1/enode 

nano static-nodes.json 

 [

  "enode://<Replace with the above node ID>@<Replace with the Public IP of your VM>:21000?discport=0&raftport=50000" 

]  

cp static-nodes.json new-node-1 

geth --datadir new-node-1 init genesis.json 

nano startnode1.sh 

#!/bin/bash 

PRIVATE_CONFIG=/yourpath/new-node-1t/tm.ipc nohup geth --datadir new-node-1 --nodiscover --verbosity 5 --networkid 31337 --raft --raftport 50000 --rpc --rpcaddr 0.0.0.0 --rpcport 22000 --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum,raft --emitcheckpoints --port 21000 >> node.log 2>&1 & 

The above configuration uses the tessera component which is configures below. If you do not want to use tessera add the following lines in this file and ignore the tessera section. 

#!/bin/bash 

PRIVATE_CONFIG=ignore nohup geth --datadir new-node-1 --nodiscover --verbosity 5 --networkid 31337 --raft --raftport 50000 --raftjoinexisting 2 --rpc --rpcaddr 0.0.0.0 --rpcport 22000 --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum,raft --emitcheckpoints --port 21000 2>>node2.log & 

chmod +x startnode1.sh 

./startnode1.sh  // DO NOT EXECUTE THIS if you are using tessera. First we should set up tessera and then execute it, 

geth attach new-node-1/geth.ipc 

Tessera deployment node 1 

In order to install tessera you have first to install Java and the proper JDK. The selection of the correct JDK depends on the tessera version.In our use case we have downloaded the tessera-app-0.10.4-app.jar and therefore we will install the JDK 11. 

Install Java: 

sudo add-apt-repository ppa:openjdk-r/ppa  

sudo apt-get update -q  

sudo apt install -y openjdk-11-jdk 

Then download the tessera app. 

cd~ 

wget https://oss.sonatype.org/service/local/repositories/releases/content/com/jpmorgan/quorum/tessera-app/0.10.4/tessera-app-0.10.4-app.jar 

mv tessera-app-0.10.4-app.jar tessera.jar 

if you want to now the path of tessera.jar run pwd. 

Inside the directory fromscratch do the following: 

mkdir new-node-1t 

cd new-node-1t 

java -jar <put tessera.jar path>/tessera.jar -keygen -filename new-node-1 

 

Then create the config.json: 

(the path with different format should be replaced by yours if it is different) 

cd /home/user/quorum/fromscratch/new-node1t/ 

nano config.json  

 

{ 

   "useWhiteList": false, 

   "jdbc": { 

       "username": "sa", 

       "password": "", 

       "url": "jdbc:h2/home/user/quorum/fromscratch/new-node-1t/db1;MODE=Oracle;TRACE_LEVEL_SYSTEM_OUT=0", 

       "autoCreateTables": true 

   }, 

   "serverConfigs":[ 

       { 

           "app":"ThirdParty", 

           "enabled": true, 

           "serverAddress": "http://localhost:9081", 

           "communicationType" : "REST" 

       }, 

       { 

           "app":"Q2T", 

           "enabled": true, 

            "serverAddress":"unix: /home/user/quorum/fromscratch/new-node-1t/tm.ipc", 

           "communicationType" : "REST" 

       }, 

       { 

           "app":"P2P", 

           "enabled": true, 

           "serverAddress":"http://localhost:9001", 

           "sslConfig": { 

               "tls": "OFF" 

           }, 

           "communicationType" : "REST" 

       } 

   ], 

   "peer": [ 

       { 

           "url": "http://localhost:9001" 

       }, 

       { 

           "url": "http://localhost:9003" 

       } 

   ], 

   "keys": { 

       "passwords": [], 

       "keyData": [ 

           { 

               "privateKeyPath": "/home/user/quorum/fromscratch/new-node-1t/new-node-1.key", 

               "publicKeyPath": "/home/user/quorum/fromscratch/new-node-1t/new-node-1.pub" 

           } 

       ] 

   }, 

   "alwaysSendTo": [] 

} 

 

To start your Tessera node go to: 

cd  /home/user/quorum/fromscratch/new-node-1t 

java -jar /home/user/tessera.jar -configfile config.json >> tessera.log 2>&1 & 

 

Then start your node : 

cd /home/user/quorum/fromscratch 

./startnode1.sh 

geth attach new-node-1/geth.ipc 

Setup the second VM 

  Access to VMs: The access to the VMs should be made by using the public key for security reasons. When we configure the access using the public key we should disable the access using password. 

ssh-copy-id <username>@<domain or IP> : Copy your public key to the VM 

sudo nano /etc/ssh/sshd_config : Access the configuration file and change Password authentication to no. 

When you are in your VM enable your Ubuntu firewall:  

sudo ufw enable : Enable firewall 

sudo ufw allow 22 : Allow port 22 for ssh 

sudo ufw allow 35570 : Allow this port for Quorum 

sudo ufw allow 50000 : Allow this port for Quorum 

sudo ufw allow 21000 : Allow this port for Quorum 

sudo ufw allow 9001 : Allow this port for Tessera 

sudo ufw allow 9003 : Allow this port for Tessera 

sudo ufw allow 9081 : Allow this port for Tessera 

sudo ufw reload : Reload firewall 

Then edit the source list to use the global: 

sudo nano /etc/apt/sources.list : Edit this file and replace every gr. or us. to empty space  

Then proceed to the installation of several packages (Ethereum, docker) as it is displayed below: 

############# Basic packets ########################### 

sudo apt-get install -y software-properties-common 

sudo add-apt-repository -y ppa:ethereum/ethereum 

sudo apt-get update 

sudo apt-get -y install ethereum 

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - 

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" 

sudo apt-get update 

sudo apt-get install -y docker-ce 

sudo usermod -a -G docker $USER 

sudo reboot 

######### Docker images GO Geth env ################ 

docker pull quorumengineering/quorum 

docker pull quorumengineering/tessera 

docker pull quorumengineering/constellation 

sudo apt-get update 

sudo apt-get -y upgrade 

wget https://dl.google.com/go/go1.12.7.linux-amd64.tar.gz 

sudo tar -xvf go1.12.7.linux-amd64.tar.gz 

sudo mv go /usr/local 

export GOROOT=/usr/local/go 

export GOPATH=$HOME/Projects/Proj1 

export PATH=$GOPATH/bin:$GOROOT/bin:$PATH 

go version 

go env 

git clone https://github.com/jpmorganchase/quorum.git 

sudo apt-get install -y make 

sudo apt-get install -y build-essential 

cd quorum  

make all   

##################### Add at the end of ~/.bashrc the following ############ 

export GOROOT=/usr/local/go 

export GOPATH=$HOME/Projects/Proj1 

export PATH=$GOPATH/bin:$GOROOT/bin:$PATH 

export PATH=/home/user/quorum/build/bin:$PATH 

####################### Create the network  ######################### 

mkdir fromscratch 

cd fromscratch  

mkdir new-node-2 

bootnode --genkey=nodekey2 

cp nodekey2 new-node-2/nodekey 

bootnode --nodekey=new-node-2/nodekey –writeaddress 

nano genesis.json 

{ 

  "alloc": { 

    "0x<Replace with the account id you entered in the genesis file of node 1>": { 

      "balance": "1000000000000000000000000000" 

    } 

}, 

 "coinbase": "0x0000000000000000000000000000000000000000", 

 "config": { 

   "homesteadBlock": 0, 

   "byzantiumBlock": 0, 

   "constantinopleBlock": 0, 

   "chainId": 10, 

   "eip150Block": 0, 

   "eip155Block": 0, 

   "eip150Hash": "0x0000000000000000000000000000000000000000000000000000000000000000", 

   "eip158Block": 0, 

   "maxCodeSize": 35, 

   "maxCodeSizeChangeBlock" : 0, 

   "isQuorum": true 

 }, 

 "difficulty": "0x0", 

 "extraData": "0x0000000000000000000000000000000000000000000000000000000000000000", 

 "gasLimit": "0xE0000000", 

 "mixhash": "0x00000000000000000000000000000000000000647572616c65787365646c6578", 

 "nonce": "0x0", 

 "parentHash": "0x0000000000000000000000000000000000000000000000000000000000000000", 

 "timestamp": "0x00" 

}    

 

nano static-nodes.json 

 [ 

  "enode://<Replace with the node ID of node 1>@<Replace with the Public IP of node 1>:21000?discport=0&raftport=50000", "enode://<Replace with the above node ID which is result of bootnode --nodekey=new-node-2/nodekey –writeaddress >@<Replace with the Public IP of your VM>:21000?discport=0&raftport=50000" 

]  

Copy the content of the static-nodes.json that you created and paste it to the static-nodes.json files of your first node. Every static-nodes.json file should be updated!!! 

 

geth --datadir new-node-2 init genesis.json 

nano startnode2.sh 

#!/bin/bash 

PRIVATE_CONFIG=/yourpath/new-node-1t/tm.ipc nohup geth --datadir new-node-2 --nodiscover --verbosity 5 --networkid 31337 --raft --raftport 50000 --rpc --rpcaddr 0.0.0.0 --rpcport 22000 --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum,raft --emitcheckpoints --port 21000 >> node.log 2>&1 & 

The above configuration uses the tessera component which is configured below. If you do not want to use tessera add the following lines in this file and ignore the tessera section. 

#!/bin/bash 

PRIVATE_CONFIG=ignore nohup geth --datadir new-node-2 --nodiscover --verbosity 5 --networkid 31337 --raft --raftport 50000 --raftjoinexisting 2 --rpc --rpcaddr 0.0.0.0 --rpcport 22000 --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum,raft --emitcheckpoints --port 21000 2>>node2.log & 

chmod +x startnode2.sh 

First you should add this node to an active peer that is the first you have created. Then start your node : 

Go to the first node: 

cd /home/user/quorum/fromscratch 

geth attach new-node-1/geth.ipc 

raft.addPeer(‘enode://<node id of the second node>@<IP of the second node> :21000?discport=0&raftport=50000') 

exit 

Then go to the second node and do the following: 

cd /home/user/quorum/fromscratch 

./startnode2.sh  // DO NOT EXECUTE THIS if you are using tessera. First we should set up tessera and then execute it, 

geth attach new-node-2/geth.ipc 

raft.cluster 

Tessera deployment node 2 

In order to install tessera you have first to install Java and the proper JDK. The selection of the correct JDK depends on the tessera version. In our use case we have downloaded the tessera-app-0.10.4-app.jar and therefore we will install the JDK 11. 

Install Java: 

sudo add-apt-repository ppa:openjdk-r/ppa  

sudo apt-get update -q  

sudo apt install -y openjdk-11-jdk 

Then download the tessera app. 

cd~ 

wget https://oss.sonatype.org/service/local/repositories/releases/content/com/jpmorgan/quorum/tessera-app/0.10.4/tessera-app-0.10.4-app.jar 

mv tessera-app-0.10.4-app.jar tessera.jar 

If you want to now the path of tessera.jar run pwd. 

Inside the directory fromscratch do the following: 

mkdir new-node-2t 

cd new-node-2t 

java -jar <put tessera.jar path>/tessera.jar -keygen -filename new-node-2 

 

Then create the config.json: 

(the path that with different format should be replaced by yours if it is different) 

cd /home/user/quorum/fromscratch/new-node2t/ 

nano config.json  

 

{ 

   "useWhiteList": false, 

   "jdbc": { 

       "username": "sa", 

       "password": "", 

       "url": "jdbc:h2/home/user/quorum/fromscratch/new-node-1t/db1;MODE=Oracle;TRACE_LEVEL_SYSTEM_OUT=0", 

       "autoCreateTables": true 

   }, 

   "serverConfigs":[ 

       { 

           "app":"ThirdParty", 

           "enabled": true, 

           "serverAddress": "http://localhost:9081", 

           "communicationType" : "REST" 

       }, 

       { 

           "app":"Q2T", 

           "enabled": true, 

            "serverAddress":"unix: /home/user/quorum/fromscratch/new-node-1t/tm.ipc", 

           "communicationType" : "REST" 

       }, 

       { 

           "app":"P2P", 

           "enabled": true, 

           "serverAddress":"http://localhost:9001", 

           "sslConfig": { 

               "tls": "OFF" 

           }, 

           "communicationType" : "REST" 

       } 

   ], 

   "peer": [ 

       { 

           "url": "http://localhost:9001" 

       }, 

       { 

           "url": "http://localhost:9003" 

       } 

   ], 

   "keys": { 

       "passwords": [], 

       "keyData": [ 

           { 

               "privateKeyPath": "/home/user/quorum/fromscratch/new-node-1t/new-node-1.key", 

               "publicKeyPath": "/home/user/quorum/fromscratch/new-node-1t/new-node-1.pub" 

           } 

       ] 

   }, 

   "alwaysSendTo": [] 

} 

 

To start your Tessera node go to: 

cd  /home/user/quorum/fromscratch/new-node-2t 

java -jar /home/user/tessera.jar -configfile config.json >> tessera.log 2>&1 & 

 

First you should add this node to an active peer that is the first you have created. Then start your node : 

Go to the first node: 

cd /home/user/quorum/fromscratch 

geth attach new-node-1/geth.ipc 

raft.addPeer(‘enode://<node id of the second node>@<IP of the second node> :21000?discport=0&raftport=50000') 

exit 

Then go to the second node and do the following: 

cd /home/user/quorum/fromscratch 

./startnode2.sh 

geth attach new-node-2/geth.ipc 

raft.cluster 

If you have completed all the steps as it was described then you should be able to see the raft cluster with two active nodes, as it is presented in the figure below. 
