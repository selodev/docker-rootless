FROM ubuntu:focal

USER root
#ENV SKIP_IPTABLES true

#ENV TZ=Asia/Ho_Chi_Minh
#RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
# https://github.com/docker/docker/blob/master/project/PACKAGERS.md#runtime-dependencies
ENV DEBIAN_FRONTEND=noninteractive
RUN set -eux; \
	  apt-get update && \
    apt-get -y install \
		btrfs-progs \
		e2fsprogs \
		iptables \
		openssl \
		uidmap \
		xfsprogs \
		xz-utils \
		pigz \
    wget \
    iproute2 \
    kmod   \ 
sudo \ 
curl \
dumb-init \ 
git \ 
    openssh-client \
    && rm -rf /var/lib/apt/lists/*


#    procps \

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

RUN echo "kernel.unprivileged_userns_clone=1" >> /etc/sysctl.conf && \
    echo 'user.max_user_namespaces=28633' >> /etc/sysctl.conf
   #echo "options overlay permit_mounts_in_userns=1" >> /etc/modprobe.d/rootless.conf && \

RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# set up subuid/subgid so that "--userns-remap=default" works out-of-the-box
RUN set -eux; \
	addgroup --system dockremap; \
	adduser --system --ingroup dockremap dockremap; \
	echo 'dockremap:165536:65536' >> /etc/subuid; \
	echo 'dockremap:165536:65536' >> /etc/subgid

RUN sudo adduser --gecos '' --disabled-password coder
RUN id -u
RUN whoami
RUN cat /etc/subuid
RUN cat /etc/subgid
# This way, if someone sets $DOCKER_USER, docker-exec will still work as
# the uid will remain the same. note: only relevant if -u isn't passed to
# docker-run.
USER 1000
ENV USER=coder
WORKDIR /home/coder
RUN id -u
RUN whoami
RUN cat /etc/subuid
RUN cat /etc/subgid

RUN curl -fsSL https://get.docker.com/rootless | sh && \
    echo "export PATH=/home/coder/bin:/sbin:/usr/sbin:$PATH" >> ~/.bashrc && \
    echo "dockerd-rootless.sh" >> ~/.bashrc && \
    echo "export XDG_RUNTIME_DIR=/home/coder/.docker/run" >> ~/.bashrc && \
    echo "export PATH=/home/coder/bin:$PATH" >> ~/.bashrc  && \
    echo "export DOCKER_HOST=unix:///home/coder/.docker/run/docker.sock" >> ~/.bashrc

#USER root
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
#RUN mkdir -p /home/coder/.local/share/code-server

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh", "--bind-addr", "0.0.0.0:8080", "--user-data-dir", "/home/coder/.local" ]

CMD [ "--auth", "none" ]
#CMD [ "sleep", "infinity" ]
