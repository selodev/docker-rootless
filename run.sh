export UID=$(id -u)
export GID=$(id -g)
docker run -it \
    --user $UID:$GID \
    --workdir="/home/$USER" \
    --volume="/etc/group:/etc/group:ro" \
    --volume="/etc/passwd:/etc/passwd:ro" \
    --volume="/etc/shadow:/etc/shadow:ro" \
    coder:latest /bin/bash
