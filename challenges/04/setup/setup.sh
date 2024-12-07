#!/bin/bash

# Update JAVA_ARGS
sed -i 's/-Djava.awt.headless=true/-Djenkins.install.runSetupWizard=false -Dhttp.auth.preference=basic -Djdk.http.auth.tunnelin.disabledSchemes= -Djava.awt.headless=true/' /lib/systemd/system/jenkins.service

# Reload to apply changes
systemctl daemon-reload
systemctl restart jenkins

# Obtain the initial admin password
INITIAL_ADMIN_PASSWORD=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)

# Download the Jenkins CLI jar
curl -O http://localhost:8080/jnlpJars/jenkins-cli.jar

# Extract proxy details from https_proxy env var
proxyAddress=$(echo $https_proxy | sed -r 's|https?://([^:]+):([^@]+)@([^:]+):([0-9]+)|\3|')
proxyPort=$(echo $https_proxy | sed -r 's|https?://([^:]+):([^@]+)@([^:]+):([0-9]+)|\4|')
proxyUser=$(echo $https_proxy | sed -r 's|https?://([^:]+):([^@]+)@([^:]+):([0-9]+)|\1|')
proxyPassword=$(echo $https_proxy | sed -r 's|https?://([^:]+):([^@]+)@([^:]+):([0-9]+)|\2|')
noProxy='localhost|127.0.0.1|::1'

# Replace placeholders in Groovy script
sed -i "s/'proxyAddress'/\"$proxyAddress\"/" /home/pslearner/challenges/04/setup/setup_proxy.groovy
sed -i "s/proxyPort/$proxyPort/" /home/pslearner/challenges/04/setup/setup_proxy.groovy
sed -i "s/'proxyUser'/\"$proxyUser\"/" /home/pslearner/challenges/04/setup/setup_proxy.groovy
sed -i "s/'proxyPassword'/\"$proxyPassword\"/" /home/pslearner/challenges/04/setup/setup_proxy.groovy
sed -i "s/'noProxy'/\"$noProxy\"/" /home/pslearner/challenges/04/setup/setup_proxy.groovy

# Setup proxy
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth admin:$INITIAL_ADMIN_PASSWORD groovy = < /home/pslearner/challenges/04/setup/setup_proxy.groovy

# Disable wizard
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth admin:$INITIAL_ADMIN_PASSWORD groovy = < /home/pslearner/challenges/04/setup/disable_wizard.groovy

# Install plugins
# java -jar jenkins-cli.jar -s http://localhost:8080/ -auth admin:$INITIAL_ADMIN_PASSWORD groovy = < /home/pslearner/challenges/04/setup/install_plugins.groovy
https_proxy="$https_proxy" java -jar jenkins-cli.jar -s http://localhost:8080/ -auth admin:$INITIAL_ADMIN_PASSWORD install-plugin https://updates.jenkins.io/download/plugins/prometheus/795.v995762102f28/prometheus.hpi


# Run the Groovy script to create the admin user
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth admin:$INITIAL_ADMIN_PASSWORD groovy = < /home/pslearner/challenges/04/setup/create_admin_user.groovy

# Clean up
# rm create_admin_user.groovy
# rm jenkins-cli.jar

echo "Jenkins setup complete. You can log in with username 'pslearner' and password 'pslearner'."