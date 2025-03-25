# deps :
##	sudo apt install docker-buildx

###################################################################################
################################  params  #########################################
###################################################################################
TAR_FILE=qroot.tar
TAR_PATH := $(shell pwd)
IMAGE_NAME=qroot_image:latest
CONTAINER_NAME=qroot_container

###################################################################################
############################# save docker script ##################################
###################################################################################
define SAVE_CHANGES_SCRIPT
#!/bin/bash
# This script commits the container and saves it to a tar file.
# It is intended to be run from within the Docker container.
docker commit $$(hostname) $(IMAGE_NAME)
docker save -o /save/$(TAR_FILE) $(IMAGE_NAME)
endef
export SAVE_CHANGES_SCRIPT

###################################################################################
###################################  help #########################################
###################################################################################
.PHONY: all build run run-gpu save clean help
help:
	@echo "Usage:"
	@echo "  make [target] [SHARE=]"
	@echo ""
	@echo "Targets:"
	@echo "  help       - Display this help message (default target)."
	@echo "  build      - Build the Docker image and save it to a tar file."
	@echo "  run        - Run the Docker container with GUI support but no GPU. Optionally specify SHARE."
	@echo "  run-gpu    - Run the Docker container with GUI and GPU support. Optionally specify SHARE."
	@echo "  save       - Save changes made in the container back to the Docker image and tar file."
	@echo "  load       - Load Docker image."
	@echo "  clean      - Clean up the Docker environment by removing the container, image, and tar file."

all: help

###################################################################################
############################### Dockerfile Definition #############################
###################################################################################
DOCKERFILE := Dockerfile
define DOCKERFILE_CONTENT
# Use a base image
FROM ubuntu:22.04 AS common-base

# Set environment variables to avoid timezone prompt
ENV DEBIAN_FRONTEND=noninteractive 
ENV TZ=Etc/UTC

# Install basic dependencies
RUN apt-get update && apt-get install -y \
    sudo \
    docker.io \
    software-properties-common \
    tzdata \
    iputils-ping \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set up a user with no password sudo
RUN mkdir -p /etc/sudoers.d && \
    useradd -m user -s /bin/bash && \
    echo "user:user" | chpasswd && \
    echo "user ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/user

# Ensure the shared directory exists
RUN mkdir -p /home/user/shared && \
    chown -R user:user /home/user/shared

# Copy and setup the save_changes script
COPY save_changes.sh /usr/local/bin/save_changes
RUN chmod +x /usr/local/bin/save_changes

USER user
WORKDIR /home/user

# Add .local/bin to PATH for user-specific scripts
ENV PATH="/home/user/.local/bin:${PATH}"

# Set the default shell to bash
CMD ["/bin/bash"]

# Extend the common-base to install additional packages
FROM common-base AS final

RUN sudo apt-get update && sudo apt-get install -y \
    vim \
    build-essential \
    git \
    wget \
    bc \
    bison \
    flex \
    libssl-dev \
    make \
    u-boot-tools \
    qemu-system-arm \
    python3 \
    unzip \
    rsync \
    cpio \
    g++ \
    file \
    libncurses-dev \
    sudo \
    gawk \
    && sudo apt-get clean \
    && sudo rm -rf /var/lib/apt/lists/*
endef
export DOCKERFILE_CONTENT


###################################################################################
###################################  build ########################################
###################################################################################
build: setup_scripts setup_dockerfile
	@echo "Building Docker image: $(IMAGE_NAME)"
	@docker build -t $(IMAGE_NAME) -f $(DOCKERFILE) .
	@echo "Saving Docker image to tar file: $(TAR_FILE)"
	@docker save -o $(TAR_FILE) $(IMAGE_NAME)
	@rm save_changes.sh $(DOCKERFILE)

load:
	@echo "Loading Docker image from tar file: $(TAR_FILE)"
	@if [ -f $(TAR_FILE) ]; then \
		docker load -i $(TAR_FILE); \
		echo "Docker image $(IMAGE_NAME) loaded successfully."; \
	else \
		echo "Error: Tar file $(TAR_FILE) not found."; \
		exit 1; \
	fi

setup_scripts:
	@echo "$$SAVE_CHANGES_SCRIPT" > save_changes.sh

setup_dockerfile:
	@echo "$$DOCKERFILE_CONTENT" > $(DOCKERFILE)

###################################################################################
###################################  run ##########################################
###################################################################################
connect:
	@if [ $$(docker ps -q -f name=$(CONTAINER_NAME)) ]; then \
		docker exec -it $(CONTAINER_NAME) /bin/bash; \
	else \
		echo "Container $(CONTAINER_NAME) is not running."; \
	fi

run:
	@if [ $$(docker ps -q -f name=$(CONTAINER_NAME)) ]; then \
		echo "Docker container is already running ; connect to $(CONTAINER_NAME)"; \
		$(MAKE) connect; \
	else \
		echo "Running Docker container with GUI support: $(CONTAINER_NAME)"; \
		docker run --name $(CONTAINER_NAME) --rm -d \
			--user $(shell id -u):$(shell id -g) \
			-v /var/run/docker.sock:/var/run/docker.sock \
			-v /tmp/.X11-unix:/tmp/.X11-unix \
			-v $(TAR_PATH):/save/ \
			-e DISPLAY=$(DISPLAY) \
			$(if $(SHARE),-v $(SHARE):/home/user/shared:rw) \
			$(IMAGE_NAME) sleep infinity; \
		$(MAKE) connect; \
	fi

stop:
	@if [ $$(docker ps -q -f name=$(CONTAINER_NAME)) ]; then \
		echo "Stopping Docker container: $(CONTAINER_NAME)"; \
		docker stop $(CONTAINER_NAME); \
		exit 0; \
	fi
	@echo "Container $(CONTAINER_NAME) is not running."

run-gpu:
	@echo "Running Docker container with GUI and GPU support: $(CONTAINER_NAME)"
	@docker run --name $(CONTAINER_NAME) --rm -it \
		--user $(shell id -u):$(shell id -g) \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-v $(TAR_PATH):/save/ \
		-e DISPLAY=$(DISPLAY) \
		--gpus all \
		$(if $(SHARE),-v $(SHARE):/home/user/shared:rw) \
		$(IMAGE_NAME)

###################################################################################
###################################  save  ########################################
###################################################################################

save:
	@echo "Saving container changes to new image..."
	@docker commit $(CONTAINER_NAME) $(IMAGE_NAME)
	@echo "Saving new image to tar file: $(TAR_FILE)"
	@docker save -o $(TAR_FILE) $(IMAGE_NAME)
	@echo "Done."

###################################################################################
###################################  clean ########################################
###################################################################################
clean:
	@echo "Cleaning up Docker environment..."
	@docker rm -f $(CONTAINER_NAME) || true
	@docker rmi $(IMAGE_NAME) || true
	@echo "Basic clean complete."

fullclean: clean
	@echo "Removing the build tar..."
	@rm -f $(TAR_FILE)
	@echo "Full cleanup complete."

