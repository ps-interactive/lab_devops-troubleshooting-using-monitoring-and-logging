// #!groovy

// import jenkins.model.Jenkins
// import jenkins.install.InstallState

// def instance = Jenkins.get()

// instance.setInstallState(InstallState.INITIAL_SETUP_COMPLETED)
// instance.save()


#!groovy

import jenkins.model.*
import hudson.util.*;
import jenkins.install.*;

def instance = Jenkins.getInstance()

instance.setInstallState(InstallState.INITIAL_SETUP_COMPLETED)
