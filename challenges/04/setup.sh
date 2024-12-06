#!/bin/bash

# Wait for Jenkins to fully start
sleep 60

# Obtain the initial admin password
INITIAL_ADMIN_PASSWORD=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)

# Download the Jenkins CLI jar
curl -O http://localhost:8080/jnlpJars/jenkins-cli.jar

# Create a Groovy script to create the admin user
cat << EOF > create_admin_user.groovy
import jenkins.model.*
import hudson.security.*


def instance = Jenkins.getInstance()
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount('pslearner', 'pslearner')
instance.setSecurityRealm(hudsonRealm)

def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
instance.setAuthorizationStrategy(strategy)
instance.save()
EOF

# Run the Groovy script to create the admin user
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth admin:$INITIAL_ADMIN_PASSWORD groovy = < create_admin_user.groovy

# Clean up
# rm create_admin_user.groovy
# rm jenkins-cli.jar

echo "Jenkins setup complete. You can log in with username 'pslearner' and password 'pslearner'."