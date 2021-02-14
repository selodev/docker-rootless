Install docker-rootless prerequisites by running the following command:
sudo bash install-docker-rootless-prerequisites.sh

From a sudo user account create docker-user application account which will run the docker application, 
and we’ll enable the ‘linger‘ functionality so that the account can use systemd services without being logged in:
$ sudo adduser docker-user
$ sudo loginctl enable-linger docker-user

Create ssh keys by executing the following commands:
$ ssh-keygen -t ed25519 -C "your_email@example.com"
$ eval "$(ssh-agent -s)"
$ ssh-add ~/.ssh/id_ed25519

Login to docker-user account using ssh
$ ssh -i ~/.ssh/id_ed25519 docker-user@localhost

Run the following command to install docker-rootless:
$ curl -fsSL https://get.docker.com/rootless | sh

[INFO] To control docker.service, run: 
`systemctl --user (start|stop|restart) docker.service`
[INFO] To run docker.service on system startup, run: 
`sudo loginctl enable-linger docker-user`

[INFO] Make sure the following environment variables are set (or add them to ~/.bashrc):

$ export PATH=$HOME/bin:$PATH
$ export DOCKER_HOST=unix:///$XDG_RUNTIME_DIR/docker.sock

Run the following commands to add environment variables to ~/.bashrc:
$ echo "export PATH='$HOME/bin:$PATH'" >> ~/.bashrc
$ echo "export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock" >> ~/.bashrc

Install docker-compose by executing the following command:
$ install-docker-compose.sh

Make sure to logout then log back in.

Run the following command to reload user services when needed:
$ systemctl --user daemon-reload
