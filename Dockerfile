FROM jenkins/jenkins:lts
MAINTAINER 4oh4
# Disable setupwizard, use configuration as code instead
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
ENV CASC_JENKINS_CONFIG /usr/share/jenkins/casc.yaml

# Derived from https://github.com/getintodevops/jenkins-withdocker (miiro@getintodevops.com)

USER root

# Make sure that the gid of the docker group matches the gid of the docker group on the host VM
# Substitute gid 120 according to your own setup
# RUN groupadd -g 120 docker

# Install the latest Docker CE binaries and add user `jenkins` to the docker group
RUN apt-get update && \
    apt-get -y --no-install-recommends install apt-transport-https \
      ca-certificates \
      curl \
      gnupg2 \
      software-properties-common && \
    curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg > /tmp/dkey; apt-key add /tmp/dkey && \
    add-apt-repository \
      "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
      $(lsb_release -cs) \
      stable" && \
   apt-get update && \
   apt-get -y --no-install-recommends install docker-ce && \
   apt-get clean && \
   usermod -aG docker jenkins

# Copy a list of plugins to the container and install them with install-plugins.sh default script
# If you want to install a specific version, include it after plugin name like so: ant:1.11
# An overview of current plugins: https://stackoverflow.com/questions/9815273/how-to-get-a-list-of-installed-jenkins-plugins-with-name-and-version-pair
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

# Copy initial configuration as Configuration as Code
COPY casc.yaml /usr/share/jenkins/casc.yaml

# drop back to the regular jenkins user - good practice
USER jenkins
