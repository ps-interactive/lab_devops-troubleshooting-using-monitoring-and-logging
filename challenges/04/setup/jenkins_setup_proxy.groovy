import jenkins.model.Jenkins
import hudson.ProxyConfiguration

def j = Jenkins.instance
def proxy = new ProxyConfiguration("proxyAddress", proxyPort as int, "proxyUser", "proxyPassword", "noProxy")
j.proxy = proxy
j.save()
println("Proxy configured")

// import jenkins.model.*
// import hudson.ProxyConfiguration

// def instance = Jenkins.getInstance()

// def proxy = new ProxyConfiguration(
//     'proxyAddress',
//     proxyPort,
//     'proxyUser', // Optional: Proxy username
//     'proxyPassword', // Optional: Proxy password
//     'noProxy' // Optional: No proxy hosts
// )

// instance.proxy = proxy
// instance.save()
