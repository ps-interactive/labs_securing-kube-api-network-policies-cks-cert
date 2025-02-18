#! /bin/bash

##############################################
########## Pluralsight Editing Only ##########
##############################################
# Setting environment variables
export http_proxy="http://${proxy_user}:${proxy_pwd}@172.31.245.222:8888" 
export https_proxy=$http_proxy

export HTTP_PROXY=$http_proxy
export HTTPS_PROXY=$http_proxy

# For assistance when converting older labs to Terrarium v4.3
rcount_file="/rcount" # path and file to store reboot count
[ -f $rcount_file ]
rcheck=$?
if [ $rcheck -ne 0 ]; then # if $rcount_file does not yet exist
    echo "0" > $rcount_file
fi

# Checks the value of the $rcount_file and returns the value.
rcount_check () {
    rcount=$(cat $rcount_file)
    return $rcount
}

# Increments the $rcount_file contents by 1. Use this before causing a reboot. 
rcount_inc () {
    rcount=$(cat $rcount_file)
    ((rcount++))
    echo "$rcount" > $rcount_file
}

# Add succcessful proxy execution message to peaceinourtime log
echo "success1">> /psorceri/peaceinourtime

###############################################################################
########## CONTENT AUTHORING  Edit Application Setup Below This Line ########## 
###############################################################################

# Start with checking reboot count.
rcount_check; r=$?
if [ $r -eq 0 ]; then
    # FIRST BOOT CYCLE STARTS HERE

    # Establishing App load tracking
    mkdir /psorceri
    echo "alias status='ls -ls /psorceri |cut -d \" \" -f 10,11,12,13,14'" >> /home/pslearner/.bashrc
    touch "/psorceri/INITIALIZING - 10%"

    echo "export NO_PROXY=localhost,127.0.0.1,10.96.0.0/12,192.168.59.0/24,192.168.49.0/24,192.168.39.0/24" >> /home/pslearner/.bashrc
    rm "/psorceri/INITIALIZING - 10%"

    # Install kubectl
    touch "/psorceri/INITIALIZING - 30%"
    sudo http_proxy="$HTTP_PROXY" https_proxy="$HTTP_PROXY" curl -LO https://dl.k8s.io/release/v1.27.4/bin/linux/amd64/kubectl
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    echo "source <(kubectl completion bash)" >> /home/pslearner/.bashrc
    rm "/psorceri/INITIALIZING - 30%"

    # Download & install minikube
    touch "/psorceri/INITIALIZING - 40%"
    sudo curl --proxy $HTTP_PROXY -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    sudo install minikube-linux-amd64 /usr/local/bin/minikube
    rm "/psorceri/INITIALIZING - 40%"

    # Configure proxy for docker
    touch "/psorceri/INITIALIZING - 50%"
    sudo mkdir -p /etc/systemd/system/docker.service.d
    sudo touch /etc/systemd/system/docker.service.d/proxy.conf
    echo "[Service]" | sudo tee -a /etc/systemd/system/docker.service.d/proxy.conf
    echo "Environment=\"HTTP_PROXY=$HTTP_PROXY\"" | sudo tee -a /etc/systemd/system/docker.service.d/proxy.conf
    echo "Environment=\"HTTPS_PROXY=$HTTP_PROXY\"" | sudo tee -a /etc/systemd/system/docker.service.d/proxy.conf
    echo "Environment=\"NO_PROXY=localhost,127.0.0.1,::1\"" | sudo tee -a /etc/systemd/system/docker.service.d/proxy.conf
    sudo systemctl daemon-reload
    sudo systemctl restart docker
	sudo docker pull nginx
	sudo docker pull quay.io/cilium/cilium:v1.14.0
    sudo docker pull quay.io/cilium/operator-generic:v1.14.0
	sudo docker pull nginx:alpine

    rm "/psorceri/INITIALIZING - 50%"

    # Start minikube
    touch "/psorceri/INITIALIZING - 60%"
    minikube_up="no"
    while [  "$minikube_up" = "no" ]
    do
    runuser -l pslearner -c 'sudo systemctl restart docker'
    sleep 2
    runuser -l pslearner -c "HTTP_PROXY=\"$HTTP_PROXY\" HTTPS_PROXY=\"$HTTP_PROXY\" minikube start --driver=docker --kubernetes-version=v1.27.4" 2>&1 | tee -a /home/pslearner/minikube.start
    if grep "Done!" /home/pslearner/minikube.start > /dev/null
    then
        minikube_up="yes"
    fi
    done
    rm /home/pslearner/minikube.start
	
	rm "/psorceri/INITIALIZING - 60%"
	
	#Download the latest version of the CLI and extract the downloaded file to your /usr/local/bin directory :

	touch "/psorceri/INITIALIZING - 70%"
	
	curl --proxy $HTTP_PROXY -LO https://github.com/cilium/cilium-cli/releases/latest/download/cilium-linux-amd64.tar.gz
	sudo tar xzvfC cilium-linux-amd64.tar.gz /usr/local/bin
    rm cilium-linux-amd64.tar.gz
    
	rm "/psorceri/INITIALIZING - 70%"


    # Enable Ingress addon

    touch "/psorceri/INITIALIZING - 80%"
		# Try enabling the Ingress addon
		runuser -l pslearner -c "minikube addons enable ingress" 2>&1 | tee -a /home/pslearner/minikube-ingress.log
		# Check if Ingress was successfully enabled
	# Cleanup temporary files
	rm /home/pslearner/minikube-ingress.log
	 
	rm "/psorceri/INITIALIZING - 80%"

    # Upload the cilium image to minikube k8s cluster
	
	touch "/psorceri/INITIALIZING - 85%"
    
	runuser -l pslearner -c "minikube image load quay.io/cilium/cilium:v1.14.0" 
	runuser -l pslearner -c "minikube image load quay.io/cilium/operator-generic:v1.14.0"
	
    
    # Install Cilium with the following command:

    runuser -l pslearner -c "cilium install --version v1.14.0 --set image.override=quay.io/cilium/cilium:v1.14.0 \
    --set operator.image.override=quay.io/cilium/operator-generic:v1.14.0 \
    2>/dev/null"
	
	rm "/psorceri/INITIALIZING - 85%"

	
    # Example Usage for App Load Tracking
    # touch "/psorceri/NMAP INITIALIZING"
    # mv "/psorceri/NMAP INITIALIZING" "/psorceri/NMAP IN PROGRESS"

    # Pull git repo for lab if your lab has lab files a repo will need to be created and the file uploaded under a "LAB_FILES"  folder to end up here:
    # git -c http.proxy=$http_proxy clone https://github.com/ps-interactive/lab_apache-commons-text-enumeration-detection.git /home/pslearner/lab

    #! SOME APPS need https proxy like so 'sudo https_proxy=$https_proxy'
    #########################################################################################################
    # Install additionally required software packages
    # Repo install - Ubuntu
    # Example1 - sudo http_proxy=$http_proxy apt install -y apache2
    # Example2 - Bypassing Acknowledgement Requirements - sudo http_proxy=$http_proxy DEBIAN_FRONTEND=noninteractive apt -y --force-yes install mysql-server
    #
    #########################################################################################################
    # # Curl package and install from binary
    # # Example - 
    # sudo curl --proxy $https_proxy https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb >> /home/pslearner/msfinstall 2>errors
    # sudo chmod 755 /home/pslearner/msfinstall
    # sudo http_proxy=$http_proxy /home/pslearner/msfinstall
    #
    ##########################################################################################################
    # # Use Docker or Docker Compose
    # 
    #   sudo mkdir -p /etc/systemd/system/docker.service.d
    #   sudo touch /etc/systemd/system/docker.service.d/proxy.conf
    #   echo "[Service]" | sudo tee -a /etc/systemd/system/docker.service.d/proxy.conf
    #   echo "Environment=\"http_proxy=$http_proxy\"" | sudo tee -a /etc/systemd/system/docker.service.d/proxy.conf
    #   echo "Environment=\"https_proxy=$http_proxy\"" | sudo tee -a /etc/systemd/system/docker.service.d/proxy.conf
    #   echo "Environment=\"NO_PROXY=localhost,127.0.0.1,::1\"" | sudo tee -a /etc/systemd/system/docker.service.d/proxy.conf
    #   echo '{"live-restore":true}' | sudo tee -a /etc/docker/daemon.json
    #   sudo systemctl daemon-reload
    #   sudo systemctl restart docker

    # # docker commands now work "docker pull" etc.
    # sudo docker pull bkimminich/juice-shop

    # # docker compose project from github
    # COURSE_DIR_PATH=/home/pslearner/os-analysis-with-wazuh
    # git -c http.proxy=$http_proxy clone https://github.com/ps-interactive/lab_os_anlaysis_wazuh.git $COURSE_DIR_PATH
    # # Update permissions because user data script runs as root
    # chown -R pslearner:pslearner $COURSE_DIR_PATH
    # cd $COURSE_DIR_PATH
    # sudo docker-compose up -d &

    # # Uncomment the line below to start the Attack Application service found on http://localhost:28657
    # sudo systemctl start attack-application.service

    # # END FIRST BOOT CYCLE. START SECOND BOOT CYCLE.
    # rcount_inc
    # sudo reboot
    # elif [ $r -eq 1 ]; then

    # # END SECOND BOOT CYCLE. START THIRD BOOT CYCLE.
    # rcount_inc
    # sudo reboot
    # elif [ $r -eq 2 ]; then

    ##############################################
    ########## END CONTENT AUTHORING #############
    ##############################################

    ##############################################
    ########## Pluralsight Editing Only ##########
    ##############################################
	touch "/psorceri/INITIALIZING - 90%"
    sudo /home/ubuntu/springtail.elf -clean
    sudo rm -f /home/ubuntu/springtail.elf
	
	minikube_up="no"
    while [  "$minikube_up" = "no" ]
    do
    runuser -l pslearner -c "minikube start --driver=docker --kubernetes-version=v1.27.4" 2>&1 | tee -a /home/pslearner/minikube.start
    if grep "Done!" /home/pslearner/minikube.start > /dev/null
    then
        minikube_up="yes"
    fi
    done
    rm /home/pslearner/minikube.start
    sudo rm -rf /home/pslearner/.minikube/logs
    runuser -l pslearner -c "sed -i '/HTTPS\?_PROXY/d' /home/pslearner/.minikube/machines/*/config.json"
    rm "/psorceri/INITIALIZING - 90%"
	
    touch "/psorceri/SYSTEM COMPLETE"

    # End message for PS DO NOT EDIT
    echo "Happy Hunting">> /home/pslearner/peaceinourtime
fi