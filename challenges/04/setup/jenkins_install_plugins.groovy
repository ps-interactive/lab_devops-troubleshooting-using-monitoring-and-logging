import jenkins.model.*
def installed = false
def initialized = false
def fileSeperator=File.separator;

def pluginslist = ['prometheus', 'blueocean']
def instance = Jenkins.getInstance()
def pm = instance.getPluginManager()
def uc = instance.getUpdateCenter()


pluginslist.each {
  println("-------------->>>>> Attempting to install Plugin "+it.trim());
  if (!pm.getPlugin(it)) {
		println("Looking UpdateCenter for " + it);
		if (!initialized) {
		  uc.updateAllSites()
		  initialized = true
		}
		def plugin = uc.getPlugin(it)
		if (plugin) {
		  println("Installing " + it)
			def installFuture = plugin.deploy()
		  while(!installFuture.isDone()) {
			println("Waiting for plugin install: " + it);
			sleep(3000)
		  }
		  installed = true
		}
	  }
	}
