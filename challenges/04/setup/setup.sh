#!/bin/bash
echo "Wait for Jenkins to fully start"
sleep 60

echo "Updating JAVA_OPTS"
sed -i 's/JAVA_OPTS=-Djava.awt.headless=true/JAVA_OPTS=-Dhttp.auth.preference=basic -Djdk.http.auth.tunneling.disabledSchemes= -Djava.awt.headless=true/' /lib/systemd/system/jenkins.service

echo "Reloading Jenkins to apply changes"
systemctl daemon-reload
systemctl restart jenkins

echo "Obtaining the initial admin password"
INITIAL_ADMIN_PASSWORD=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)

echo "Download the Jenkins CLI jar"
curl -O http://localhost:8080/jnlpJars/jenkins-cli.jar

echo "Extract proxy details from https_proxy env var"
proxyAddress=$(echo $https_proxy | sed -r 's|https?://([^:]+):([^@]+)@([^:]+):([0-9]+)|\3|')
proxyPort=$(echo $https_proxy | sed -r 's|https?://([^:]+):([^@]+)@([^:]+):([0-9]+)|\4|')
proxyUser=$(echo $https_proxy | sed -r 's|https?://([^:]+):([^@]+)@([^:]+):([0-9]+)|\1|')
proxyPassword=$(echo $https_proxy | sed -r 's|https?://([^:]+):([^@]+)@([^:]+):([0-9]+)|\2|')
noProxy='localhost|127.0.0.1|::1'

echo "Replace placeholders in Groovy script"
sed -i "s/'proxyAddress'/\"$proxyAddress\"/" /home/pslearner/challenges/04/setup/jenkins_setup_proxy.groovy
sed -i "s/proxyPort/$proxyPort/" /home/pslearner/challenges/04/setup/jenkins_setup_proxy.groovy
sed -i "s/'proxyUser'/\"$proxyUser\"/" /home/pslearner/challenges/04/setup/jenkins_setup_proxy.groovy
sed -i "s/'proxyPassword'/\"$proxyPassword\"/" /home/pslearner/challenges/04/setup/jenkins_setup_proxy.groovy
sed -i "s/'noProxy'/\"$noProxy\"/" /home/pslearner/challenges/04/setup/jenkins_setup_proxy.groovy

echo "Setup proxy"
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth admin:$INITIAL_ADMIN_PASSWORD groovy = < /home/pslearner/challenges/04/setup/jenkins_setup_proxy.groovy

echo "Disable wizard"
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth admin:$INITIAL_ADMIN_PASSWORD groovy = < /home/pslearner/challenges/04/setup/jenkins_disable_wizard.groovy

echo "Install plugins"
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth admin:$INITIAL_ADMIN_PASSWORD groovy = < /home/pslearner/challenges/04/setup/jenkins_install_plugins.groovy

echo "Create admin user"
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth admin:$INITIAL_ADMIN_PASSWORD groovy = < /home/pslearner/challenges/04/setup/jenkins_create_admin_user.groovy

echo "Remove proxy from Jenkins config"
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth admin:$INITIAL_ADMIN_PASSWORD groovy = < /home/pslearner/challenges/04/setup/jenkins_remove_proxy.groovy


echo "Jenkins setup complete"