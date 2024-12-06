#!/usr/bin/python
import sys
import zipfile
import requests


def download_plugin(name,version):
    url = "http://updates.jenkins-ci.org/download/plugins/%s/%s/%s.hpi" % (name,version,name)
    print(f"downloading: {pluginUrl}")
    filename = "%s.hpi" % name
    response = requests.get(url, proxies=proxies)
    with open(filename, 'wb') as my_file:
        my_file.write(response.content)
    download_dependencies(filename)

def download_dependencies(filename):
    z = zipfile.ZipFile(filename, "r")        
    manifestPath = "META-INF/MANIFEST.MF"        
    bytes = z.read(manifestPath)
    dependencies = [x for x in bytes.decode("utf-8").split("\n") if "Dependencies" in x]
    for dep in dependencies:
        _dep = dep.strip()
        _deps = _dep.split(":")
        print(_deps)
        name = _deps[1].strip()
        version = _deps[2].strip()
        download_plugin(name,version)


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("usage sample: python download_plugin.py junit 1.19")
        sys.exit(1)
    name = sys.argv[1]
    version = sys.argv[2]
    print(f"download {name} {version}")
    download_plugin(name,version)