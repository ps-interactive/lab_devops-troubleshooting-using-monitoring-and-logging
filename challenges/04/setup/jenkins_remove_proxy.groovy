import jenkins.model.*
import hudson.ProxyConfiguration

def instance = Jenkins.getInstance()

instance.proxy = null
instance.save()

