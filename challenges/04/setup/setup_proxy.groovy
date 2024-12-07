import jenkins.model.*
import hudson.ProxyConfiguration

def instance = Jenkins.getInstance()

def proxy = new ProxyConfiguration(
    'proxyAddress',
    proxyPort,
    'proxyUser', // Optional: Proxy username
    'proxyPassword', // Optional: Proxy password
    'noProxy' // Optional: No proxy hosts
)

instance.proxy = proxy
instance.save()
