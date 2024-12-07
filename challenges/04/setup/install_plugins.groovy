import jenkins.model.*
import java.util.logging.Logger
def logger = Logger.getLogger("install_plugins.groovy")
def installed = false
def initialized = false
def fileSeperator=File.separator;
println("Plugins Count Before Installation: "+Jenkins.instance.pluginManager.plugins.size())

def pluginslist = ['prometheus']
def instance = Jenkins.getInstance()
def pm = instance.getPluginManager()
def uc = instance.getUpdateCenter()


logger.info("Pluginslist count: "+pluginslist.size())
logger.info("Pluginslist to be installed: "+pluginslist)

if(pluginslist.size()>0){
pluginslist.each {
  logger.info "-------------->>>>> Installing Plugin "+it.trim();
  if (!pm.getPlugin(it)) {
		logger.info("Looking UpdateCenter for " + it)
		if (!initialized) {
		  uc.updateAllSites()
		  initialized = true
		}
		def plugin = uc.getPlugin(it)
		if (plugin) {
		  logger.info("Installing " + it)
			def installFuture = plugin.deploy()
		  while(!installFuture.isDone()) {
			logger.info("Waiting for plugin install: " + it)
			sleep(3000)
		  }
		  installed = true
		}
	  }
	}
	println("Plugins Count after Installation: "+Jenkins.instance.pluginManager.plugins.size())
}
else{
	println("Zero Plugins specified in pluginslist.cfg file, skipping installation step")
}


if (installed) {
  logger.info("Plugins installed, initiating jenkins restart...!")
  instance.save()
  instance.restart()
}