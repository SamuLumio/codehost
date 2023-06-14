
codehost
========


A docker container for running VSCode and Dev Containers on a remote machine.

You can connect with VSCode's Remote SSH extension, and because this container has a nested instance of Docker installed, you can use Dev Containers to have seperate development environments for each project. (Which means you don't have to worry about what build tools and dependencies might be included in this image)


## Quick setup

Create the container like this:
```
docker run \
    --name codehost \
    --privileged \
    --publish 7837:22 \
    --publish 7838:7838 \
    --volume codehost-data/config:/config \
    --volume codehost-data/docker:/var/lib/docker \
    --volume $HOME/Projects:/projects \
    --env GITHUB_USER=(your username) \
    samulumio/codehost 
```
*(the container has to have the `--privileged` flag for nested Docker to work)*

And set in local VSCode settings:

```
"remote.SSH.serverPickPortsFromRange": {
  "(hostname of remote machine)": "7838-7838"
}
```

*(at the bottom is an explanation on what the ports and volumes do)*


## Accessing the container

Codehost is accessed with SSH using keys linked to your Github account – just supply your Github username to the environment variable `GITHUB_USER`. You can then connect with VSCode's SSH extension (port 7837 if you're using the quick setup example). The login user is `codehost`.

---

If you haven't yet linked an SSH key to your Github account, click on your profile picture and go to Settings > SSH and GPG keys, and add it. This is only your public key, so you're not giving Github any private access. If the container is already running, restart it to apply the added key.

If you have no clue about SSH keys, [here](https://git-scm.com/book/en/v2/Git-on-the-Server-Generating-Your-SSH-Public-Key) is a quick guide on how to create one. 

---


## Volume and port explanations

- All the persistent files are stored in `/config`, which is also the home folder of the codehost user
- You should bind your projects folder from the host to something like `/projects` and use that in the container 
- Optionally map `/var/lib/docker` to not have to rebuild dev containers when codehost is updated or recreated

This container uses normal SSH port 22, which you can map to any desired free port (7837 in the config example). You will also have to map another port for VSCode to use for its remote tunnel (7838 in the config example)

VSCode has to be told to use the tunneling port that's published in the container. This is done in the example configuration by setting `remote.SSH.serverPickPortsFromRange` to a range that only includes the published port.
