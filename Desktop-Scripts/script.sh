#!/bin/bash

# User configuration
BASE_DIR=$HOME/SteamDeckPrinter
CONTAINER_NAME=steamdeck-cupsd

start_server() {
    mkdir -p $BASE_DIR/jobs
    mkdir -p $BASE_DIR/jobs-done
    mkdir -p $BASE_DIR/cups
    podman run \
            --replace \
            -d \
            -p 1024:631 \
            -v /var/run/dbus:/var/run/dbus \
            -v $BASE_DIR/jobs:/jobs \
            -v $BASE_DIR/cups:/etc/cups \
            --name $CONTAINER_NAME \
            docker.io/olbat/cupsd 
    echo "Sleeping for 5 seconds to allow server loaded successfully." && sleep 5
    echo "CUPS server is live."
    echo "Open your web browser end dial http://127.0.0.1:1024 to open CUPS configuration page."
}

stop_server() {
    podman stop $CONTAINER_NAME
    echo "Podman container stopped."
}

setup_server() {
    start_server
    podman cp cupsd:/etc/cups $BASE_DIR
    echo "CUPS configuration copied to host."
}

start_print_job() {
    podman exec $CONTAINER_NAME /bin/bash -c "lpr /jobs/*"
    mv $BASE_DIR/jobs/* $BASE_DIR/jobs-done
}
