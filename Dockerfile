FROM docker:dind
LABEL org.opencontainers.image.source=https://github.com/samulumio/codehost

# Enable repositories for image creation
RUN set -x \
    && sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories \
    && apk upgrade

# Install VSCode dependencies
# (the code server itself is installed when connecting for the first time)
RUN apk --no-cache add gcompat libstdc++ bash curl

# Ensure VSCode credentials persist when updating/recreating the container
ENV VSCODE_CLI_USE_FILE_KEYCHAIN=true VSCODE_CLI_DISABLE_KEYCHAIN_ENCRYPT=true

# Setup SSH
RUN apk --no-cache add openssh-server openrc
RUN echo -e \
    "PermitRootLogin no \n" \
    "AllowUsers codehost \n" \
    "PasswordAuthentication no \n" \
    "KbdInteractiveAuthentication no \n" \
    "PubkeyAuthentication yes \n" \
    "AuthorizedKeysFile	/config/.ssh/authorized_keys \n" \
    "HostKey /config/.ssh/ssh_host_rsa_key \n" \
    "HostKey /config/.ssh/ssh_host_ecdsa_key \n" \
    "HostKey /config/.ssh/ssh_host_ed25519_key \n" \
    "AllowAgentForwarding yes \n" \
    "AllowTcpForwarding yes \n" \
    "X11Forwarding yes \n" \
    > /etc/ssh/sshd_config
EXPOSE 22

# Add (unlocked) codehost user
RUN addgroup docker \
    && adduser -h /config -G docker -s /bin/sh -D codehost \
    && echo "codehost:*" | chpasswd

# Custom entrypoint
COPY entrypoint.sh /
RUN chmod +x -v /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
RUN echo "Logged into codehost" > /etc/motd
