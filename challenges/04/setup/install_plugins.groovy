import jenkins.model.*
import hudson.PluginManager
import hudson.model.UpdateCenter
import java.util.concurrent.Future

def instance = Jenkins.getInstance()
def pm = instance.pluginManager
def uc = instance.updateCenter

// List of recommended plugins
def plugins = [
    'git',                 // Git plugin
    'workflow-aggregator', // Pipeline
    'blueocean',           // Blue Ocean
    'credentials',         // Credentials
    'job-dsl',             // Job DSL
    'matrix-auth',         // Matrix Authorization Strategy
    'ldap',                // LDAP
    'email-ext',           // Email Extension
    'mailer',              // Mailer
    'cloudbees-folder',    // Folders
	'prometheus',          // Prometheus metrics plugin
	'support-core',        // Support Core for enhanced login
]

plugins.each {
    if (!pm.getPlugin(it)) {
        def plugin = uc.getPlugin(it)
        if (plugin) {
            Future installFuture = plugin.deploy(true)
            installFuture.get()
            println "Installed: ${it}"
        } else {
            println "Plugin not found: ${it}"
        }
    } else {
        println "Already installed: ${it}"
    }
}

instance.save()
