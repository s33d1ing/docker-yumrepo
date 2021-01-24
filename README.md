# Docker YUM Repository

This image is based on the official [NGINX](https://hub.docker.com/_/nginx) image and has been modified to monitor and serve a YUM repository.

## Supported Architectures

Although the NGINX images support multiple architectures, this image is only built as `x86-64`.

## Usage

Here are some example snippets to help you get started creating a container.

### docker-compose

```yaml
version: "3.8"

services:
  web-server:
    image: s33d1ing/yumrepo
    ports:
      - "80:80"
    volumes:
      - ./run/repo:/var/repo:rw
    hostname: yum-repo
    environment:
      - REPO_PORT=80
      - REPO_PATH=/var/repo
      - REPO_DEPTH=2

  centos-7:
    image: centos:centos7
    volumes:
      - ./run/container.repo:/etc/yum.repos.d/container.repo:ro
    command: yum --disablerepo=* --enablerepo=container -y install hello
    depends_on:
      - web-server

  centos-8:
    image: centos:centos8
    volumes:
      - ./run/container.repo:/etc/yum.repos.d/container.repo:ro
    command: yum --disablerepo=* --enablerepo=container -y install hello
    depends_on:
      - web-server
```

### docker cli

```shell
docker run -d --name=yum-repo -p 80:80 -v ./run/repo:/var/repo s33d1ing/yumrepo
```

## Parameters

You must mount a directory inside the container that contains all packages that you want serve. This directory may have other nested directories to respect the structure of a YUM repository (i.e. 7/x86_64, 8/x86_64). In this case, you would leave `REPO_DEPTH` as the default value of `2`. If the repository has a flat directory structure, you would set `REPO_DEPTH` to `0`.

Optionally, the repository's internal port and path can be changed. Keep in mind that the internal port (i.e. `-p 80:`**`80`**) and `REPO_PORT` should match. Likewise, the internal path (i.e. `-v ./run/repo:`**`/var/repo`**) and `REPO_PATH` should match.

| Parameter | Function |
| --- | --- |
| `-p 80:80` | Exposed port for the web server. |
| `-e REPO_PORT=80` | Repository listening port. |
| `-e REPO_PATH=/var/repo` | Base path of the repository inside the container. |
| `-e REPO_DEPTH=2` | Number of levels to look for packages inside the repository. |
| `-v /var/repo` | Where to mount the repository inside the container. |

## Application Setup

Once the YUM repository is running, the clients must be configured. Add the following config to `/etc/yum.repos.d/container.repo` on the client. Be sure to swap out `yum-repo` with your Docker host's or container's IP address. Then run the next command to perform an action using the container repository.

```shell
[container]
name = Container Repo
baseurl = http://yum-repo/$releasever/$basearch/
gpgcheck = 0
```

```shell
yum --disablerepo=* --enablerepo=container <action> <package>
```

## Building locally

If you want to make local modifications to these images for development purposes or just to customize the logic:

```shell
git clone https://github.com/s33d1ing/docker-yumrepo.git

cd docker-yumrepo

docker-compose up -d --build
```
