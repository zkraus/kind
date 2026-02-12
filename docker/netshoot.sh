
export DOCKER_NETSHOOT_NAME=netshoot

function netshoot() {
    if docker container inspect "${DOCKER_NETSHOOT_NAME}" > /dev/null 2>&1; then
        echo "Container ${DOCKER_NETSHOOT_NAME} exists"

        if docker inspect -f '{{.State.Status}}' "${DOCKER_NETSHOOT_NAME}" | grep -q "running"; then
            echo "Container ${DOCKER_NETSHOOT_NAME} running"

        else
            echo "Container ${DOCKER_NETSHOOT_NAME} is not running"
            docker start "${DOCKER_NETSHOOT_NAME}"

        fi
        echo "Connecting to ${DOCKER_NETSHOOT_NAME}"
        docker exec -it ${DOCKER_NETSHOOT_NAME} zsh

    else
        echo "Launching new ${DOCKER_NETSHOOT_NAME}"
        docker run -it --name "${DOCKER_NETSHOOT_NAME}"
    fi
}