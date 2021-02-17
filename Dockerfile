FROM ubuntu:groovy

#USER root
ENV SKIP_IPTABLES true
ENV DEBIAN_FRONTEND noninteractive

#ENV TZ=Asia/Ho_Chi_Minh
#RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && \
    apt-get install -y \
    sudo \
    curl \
    uidmap \
    iptables \
    slirp4netns \
build-essential \
&& rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    apt-get install -y \
    dumb-init \
    git \
    procps \
    openssh-client \
    lsb-release \
  && rm -rf /var/lib/apt/lists/*
#COPY modprobe.sh /usr/local/bin/modprobe
#RUN sudo chmod +x /usr/local/bin/modprobe/modprobe.sh
#RUN modprobe ip_tables

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

RUN chmod u+s /usr/bin/new[ug]idmap
RUN chmod 4755 /usr/bin/newuidmap /usr/bin/newuidmap 
#RUN sudo echo "kernel.unprivileged_userns_clone=1" >> /etc/sysctl.conf && \
RUN echo 'kernel.unprivileged_userns_clone=1' > /etc/sysctl.d/userns.conf 
   #echo "options overlay permit_mounts_in_userns=1" >> /etc/modprobe.d/rootless.conf && \
    #sh -c "echo 1 > /proc/sys/kernel/unprivileged_userns_clone" && \
#    sed -i '/^GRUB_CMDLINE_LINUX/ s/"$/ systemd.unified_cgroup_hierarchy=1"/' /etc/default/grub
#RUN sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="systemd.unified_cgroup_hierarchy=1"' /etc/default/grub   
#RUN sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="systemd.unified_cgroup_hierarchy=1"/' /etc/default/grub


RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

ENV LANG en_US.utf8

RUN chmod 4755 /usr/bin/newuidmap
RUN adduser --gecos '' --disabled-password coder
#RUN loginctl enable-linger coder

# systemd-container: for machinectl

# create a default user preconfigured for running rootless dockerd

# create a default user preconfigured for running rootless dockerd
#RUN set -eux; \
#	adduser -h /home/coder -g 'Rootless' -D -u 1000 coder; \
#	echo 'coder:100000:65536' >> /etc/subuid; \
#	echo 'coder:100000:65536' >> /etc/subgid

#RUN sudo chmod +x /home/coder/docker-entrypoint.sh
#RUN chmod +x /home/coder/rootless.sh
USER coder

WORKDIR /home/coder
#USER coder

RUN curl -fsSL https://get.docker.com/rootless | sh && \
    echo "export PATH=/home/coder/bin:/sbin:/usr/sbin:$PATH" >> ~/.bashrc && \
    echo "export XDG_RUNTIME_DIR=/home/coder/.docker/run" >> ~/.bashrc && \
    echo "export PATH=/home/coder/bin:$PATH" >> ~/.bashrc  && \
    echo "export DOCKER_HOST=unix:///home/coder/.docker/run/docker.sock" >> ~/.bashrc


#RUN curl -L "https://github.com/docker/compose/releases/download/1.28.2/docker-compose-$(uname -s)-$(uname -m)" -o ~/bin/docker-compose && \
#    chmod +x ~/bin/docker-compose

# Install NVM
#RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
#RUN NVM_DIR="$HOME/.nvm"
#RUN for e in node npm; do echo -n "${e} version: " && ${e} --version; done

# Install Coder
RUN  echo "**** install code-server ****" && \
     if [ -z ${CODE_RELEASE+x} ]; then \
     CODE_RELEASE=$(curl -sX GET "https://api.github.com/repos/cdr/code-server/releases/latest" \
      | awk '/tag_name/{print $4;exit}' FS='[""]'); \
      fi && \
      CODE_VERSION=$(echo "$CODE_RELEASE" | awk '{print substr($1,2); }') && \
      mkdir -p ~/.local/lib ~/.local/bin && \
      curl -fL https://github.com/cdr/code-server/releases/download/v"$CODE_VERSION"/code-server-"$CODE_VERSION"-linux-amd64.tar.gz \
      | tar -C ~/.local/lib -xz &&\
      mv ~/.local/lib/code-server-"$CODE_VERSION"-linux-amd64 ~/.local/lib/code-server-"$CODE_VERSION" &&\
      ln -s ~/.local/lib/code-server-"$CODE_VERSION"/bin/code-server ~/.local/bin/code-server && \
      export PATH="~/.local/bin:$PATH"


#RUN mkdir -p /home/coder/.config
RUN mkdir -p /home/coder/.local/share/code-server
RUN chown -R coder:coder $HOME
EXPOSE 8080
# This way, if someone sets $DOCKER_USER, docker-exec will still work as
# the uid will remain the same. note: only relevant if -u isn't passed to
# docker-run.
#USER 1000
#ENV USER=coder
#ENTRYPOINT ["/home/coder/docker-entrypoint.sh"]
#CMD ["/bin/bash"]

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh", "--bind-addr", "0.0.0.0:8080", "--user-data-dir", "/home/coder/.local" ]

CMD [ "--auth", "none" ]
