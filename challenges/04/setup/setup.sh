cat << 'EOF' > /home/pslearner/challenges/04/setup/setup.sh
#!/bin/bash
set -e

JENKINS_URL="http://localhost:8080"
JENKINS_CONTAINER="jenkins-docker"
JENKINS_HOME_HOST="/home/pslearner/jenkins"
SETUP_DIR="/home/pslearner/challenges/04/setup"
CLI_JAR="/tmp/jenkins-cli.jar"

# Clean problematic shebangs from Groovy files
sed -i '/^#!/d' "$SETUP_DIR"/*.groovy

echo "Wait for Jenkins to be fully ready (password file + HTTP + CLI subsystem)"
for i in {1..60}; do
  if sudo test -f "$JENKINS_HOME_HOST/secrets/initialAdminPassword" && \
     curl -fs "$JENKINS_URL/login" >/dev/null 2>&1; then
    echo "Jenkins is responding; allowing extra time for CLI subsystem..."
    sleep 15
    break
  fi
  sleep 5
done

echo "Get initial admin password"
INITIAL_ADMIN_PASSWORD=$(sudo cat "$JENKINS_HOME_HOST/secrets/initialAdminPassword")

echo "Download Jenkins CLI"
curl -fsSL -o "$CLI_JAR" "$JENKINS_URL/jnlpJars/jenkins-cli.jar"

echo "Extract proxy values"
proxyAddress=$(echo "$https_proxy" | sed -r 's|https?://([^:]+):([^@]+)@([^:]+):([0-9]+)|\3|')
proxyPort=$(echo "$https_proxy" | sed -r 's|https?://([^:]+):([^@]+)@([^:]+):([0-9]+)|\4|')
proxyUser=$(echo "$https_proxy" | sed -r 's|https?://([^:]+):([^@]+)@([^:]+):([0-9]+)|\1|')
proxyPassword=$(echo "$https_proxy" | sed -r 's|https?://([^:]+):([^@]+)@([^:]+):([0-9]+)|\2|')
noProxy='localhost|127.0.0.1|::1'

echo "Update proxy groovy script"
sed -i "s#\"proxyAddress\"#\"$proxyAddress\"#" "$SETUP_DIR/jenkins_setup_proxy.groovy"
sed -i "s#proxyPort#$proxyPort#" "$SETUP_DIR/jenkins_setup_proxy.groovy"
sed -i "s#\"proxyUser\"#\"$proxyUser\"#" "$SETUP_DIR/jenkins_setup_proxy.groovy"
sed -i "s#\"proxyPassword\"#\"$proxyPassword\"#" "$SETUP_DIR/jenkins_setup_proxy.groovy"
sed -i "s#\"noProxy\"#\"$noProxy\"#" "$SETUP_DIR/jenkins_setup_proxy.groovy"

echo "Run Jenkins setup scripts"
java -jar "$CLI_JAR" -s "$JENKINS_URL/" -auth admin:$INITIAL_ADMIN_PASSWORD groovy = < "$SETUP_DIR/jenkins_setup_proxy.groovy"
java -jar "$CLI_JAR" -s "$JENKINS_URL/" -auth admin:$INITIAL_ADMIN_PASSWORD groovy = < "$SETUP_DIR/jenkins_disable_wizard.groovy"
java -jar "$CLI_JAR" -s "$JENKINS_URL/" -auth admin:$INITIAL_ADMIN_PASSWORD groovy = < "$SETUP_DIR/jenkins_install_plugins.groovy"
java -jar "$CLI_JAR" -s "$JENKINS_URL/" -auth admin:$INITIAL_ADMIN_PASSWORD groovy = < "$SETUP_DIR/jenkins_create_admin_user.groovy"

echo "Restart Jenkins container to activate plugins"
sudo docker restart "$JENKINS_CONTAINER"

echo "Jenkins setup complete"
EOF

chmod +x /home/pslearner/challenges/04/setup/setup.sh
#previous edits
# cat << 'EOF' > /home/pslearner/challenges/04/setup/setup.sh
# #!/bin/bash
# set -e

# JENKINS_URL="http://localhost:8080"
# JENKINS_CONTAINER="jenkins-docker"
# JENKINS_HOME_HOST="/home/pslearner/jenkins"
# SETUP_DIR="/home/pslearner/challenges/04/setup"
# CLI_JAR="/tmp/jenkins-cli.jar"

# # Clean problematic shebangs from Groovy files
# sed -i '/^#!/d' "$SETUP_DIR"/*.groovy

# echo "Wait for Jenkins to be ready"
# for i in {1..24}; do
#   if curl -fs "$JENKINS_URL/login" >/dev/null 2>&1; then
#     break
#   fi
#   sleep 5
# done

# echo "Get initial admin password"
# INITIAL_ADMIN_PASSWORD=$(sudo cat "$JENKINS_HOME_HOST/secrets/initialAdminPassword")

# echo "Download Jenkins CLI"
# curl -fsSL -o "$CLI_JAR" "$JENKINS_URL/jnlpJars/jenkins-cli.jar"

# echo "Extract proxy values"
# proxyAddress=$(echo "$https_proxy" | sed -r 's|https?://([^:]+):([^@]+)@([^:]+):([0-9]+)|\3|')
# proxyPort=$(echo "$https_proxy" | sed -r 's|https?://([^:]+):([^@]+)@([^:]+):([0-9]+)|\4|')
# proxyUser=$(echo "$https_proxy" | sed -r 's|https?://([^:]+):([^@]+)@([^:]+):([0-9]+)|\1|')
# proxyPassword=$(echo "$https_proxy" | sed -r 's|https?://([^:]+):([^@]+)@([^:]+):([0-9]+)|\2|')
# noProxy='localhost|127.0.0.1|::1'

# echo "Update proxy groovy script"
# # sed -i "s|\"proxyAddress\"|\"$proxyAddress\"|" "$SETUP_DIR/jenkins_setup_proxy.groovy"
# # sed -i "s|proxyPort|$proxyPort|" "$SETUP_DIR/jenkins_setup_proxy.groovy"
# # sed -i "s|\"proxyUser\"|\"$proxyUser\"|" "$SETUP_DIR/jenkins_setup_proxy.groovy"
# # sed -i "s|\"proxyPassword\"|\"$proxyPassword\"|" "$SETUP_DIR/jenkins_setup_proxy.groovy"
# # sed -i "s|\"noProxy\"|\"$noProxy\"|" "$SETUP_DIR/jenkins_setup_proxy.groovy"

# sed -i "s#\"proxyAddress\"#\"$proxyAddress\"#" "$SETUP_DIR/jenkins_setup_proxy.groovy"
# sed -i "s#proxyPort#$proxyPort#" "$SETUP_DIR/jenkins_setup_proxy.groovy"
# sed -i "s#\"proxyUser\"#\"$proxyUser\"#" "$SETUP_DIR/jenkins_setup_proxy.groovy"
# sed -i "s#\"proxyPassword\"#\"$proxyPassword\"#" "$SETUP_DIR/jenkins_setup_proxy.groovy"
# sed -i "s#\"noProxy\"#\"$noProxy\"#" "$SETUP_DIR/jenkins_setup_proxy.groovy"

# echo "Run Jenkins setup scripts"
# # 1. Setup Proxy (Crucial for plugin downloads)
# java -jar "$CLI_JAR" -s "$JENKINS_URL/" -auth admin:$INITIAL_ADMIN_PASSWORD groovy = < "$SETUP_DIR/jenkins_setup_proxy.groovy"

# # 2. Disable Wizard
# java -jar "$CLI_JAR" -s "$JENKINS_URL/" -auth admin:$INITIAL_ADMIN_PASSWORD groovy = < "$SETUP_DIR/jenkins_disable_wizard.groovy"

# # 3. Install Plugins (Prometheus, Blue Ocean, Pipeline)
# java -jar "$CLI_JAR" -s "$JENKINS_URL/" -auth admin:$INITIAL_ADMIN_PASSWORD groovy = < "$SETUP_DIR/jenkins_install_plugins.groovy"

# # 4. Create Admin User
# java -jar "$CLI_JAR" -s "$JENKINS_URL/" -auth admin:$INITIAL_ADMIN_PASSWORD groovy = < "$SETUP_DIR/jenkins_create_admin_user.groovy"

# echo "Restart Jenkins container to activate plugins"
# sudo docker restart "$JENKINS_CONTAINER"

# echo "Jenkins setup complete"
# EOF

# chmod +x /home/pslearner/challenges/04/setup/setup.sh

#ORIGINAL
# #!/bin/bash
# echo "Wait for Jenkins to fully start"
# sleep 60

# echo "Updating JAVA_OPTS"
# sed -i 's/JAVA_OPTS=-Djava.awt.headless=true/JAVA_OPTS=-Dhttp.auth.preference=basic -Djdk.http.auth.tunneling.disabledSchemes= -Djava.awt.headless=true/' /lib/systemd/system/jenkins.service

# echo "Reloading Jenkins to apply changes"
# systemctl daemon-reload
# systemctl restart jenkins

# echo "Obtaining the initial admin password"
# INITIAL_ADMIN_PASSWORD=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)

# echo "Download the Jenkins CLI jar"
# curl -O http://localhost:8080/jnlpJars/jenkins-cli.jar

# echo "Extract proxy details from https_proxy env var"
# proxyAddress=$(echo $https_proxy | sed -r 's|https?://([^:]+):([^@]+)@([^:]+):([0-9]+)|\3|')
# proxyPort=$(echo $https_proxy | sed -r 's|https?://([^:]+):([^@]+)@([^:]+):([0-9]+)|\4|')
# proxyUser=$(echo $https_proxy | sed -r 's|https?://([^:]+):([^@]+)@([^:]+):([0-9]+)|\1|')
# proxyPassword=$(echo $https_proxy | sed -r 's|https?://([^:]+):([^@]+)@([^:]+):([0-9]+)|\2|')
# noProxy='localhost|127.0.0.1|::1'

# echo "Replace placeholders in Groovy script"
# sed -i "s/'proxyAddress'/\"$proxyAddress\"/" /home/pslearner/challenges/04/setup/jenkins_setup_proxy.groovy
# sed -i "s/proxyPort/$proxyPort/" /home/pslearner/challenges/04/setup/jenkins_setup_proxy.groovy
# sed -i "s/'proxyUser'/\"$proxyUser\"/" /home/pslearner/challenges/04/setup/jenkins_setup_proxy.groovy
# sed -i "s/'proxyPassword'/\"$proxyPassword\"/" /home/pslearner/challenges/04/setup/jenkins_setup_proxy.groovy
# sed -i "s/'noProxy'/\"$noProxy\"/" /home/pslearner/challenges/04/setup/jenkins_setup_proxy.groovy

# echo "Setup proxy"
# java -jar jenkins-cli.jar -s http://localhost:8080/ -auth admin:$INITIAL_ADMIN_PASSWORD groovy = < /home/pslearner/challenges/04/setup/jenkins_setup_proxy.groovy

# echo "Disable wizard"
# java -jar jenkins-cli.jar -s http://localhost:8080/ -auth admin:$INITIAL_ADMIN_PASSWORD groovy = < /home/pslearner/challenges/04/setup/jenkins_disable_wizard.groovy

# echo "Install plugins"
# java -jar jenkins-cli.jar -s http://localhost:8080/ -auth admin:$INITIAL_ADMIN_PASSWORD groovy = < /home/pslearner/challenges/04/setup/jenkins_install_plugins.groovy

# echo "Create admin user"
# java -jar jenkins-cli.jar -s http://localhost:8080/ -auth admin:$INITIAL_ADMIN_PASSWORD groovy = < /home/pslearner/challenges/04/setup/jenkins_create_admin_user.groovy

# echo "Remove proxy from Jenkins config"
# java -jar jenkins-cli.jar -s http://localhost:8080/ -auth admin:$INITIAL_ADMIN_PASSWORD groovy = < /home/pslearner/challenges/04/setup/jenkins_remove_proxy.groovy


# echo "Jenkins setup complete"
