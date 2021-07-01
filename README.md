
# 👌 Github Actions self-hosted runner provisioning

> Simple Docker images for starting self-hosted Github Actions runner(s).

![Screenshot Github self-hosted runners](./screenshot1.png)

[Github official documentation for self-hosted runners.](https://help.github.com/en/actions/hosting-your-own-runners/adding-self-hosted-runners)

## 🚀 Quick start

Add your self-hosted runner from your repository settings:

- Go to repository > settings > actions
- Click on "Add runner"
- Copy the URL and token

```sh
# start a runner on your server

$ docker run -d \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /tmp:/tmp \
    -e GH_REPOSITORY=xxxxxxxxxxxx \
    -e GH_RUNNER_TOKEN=xxxxxxxxxxxxx \
    -e GH_RUNNER_LABELS=node,golang,java,node \
    cdotyone/github-actions-runner:latest
```

```yaml
# .github/workflows/main.yml

on:
  - push

jobs:
  example:
    runs-on: self-hosted
    steps:
      - name: Hello world
        run: echo "Hello world"
```

```yaml
# .github/workflows/main.yml

on:
  - push

jobs:
  frontend:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v2
      - name: Fetch dependencies
        run: yarn
      - name: Build application
        run: npm run build
      - name: Execute tests
        run: npm run test
```

### Missing language support ?

You just need to write a Dockerfile starting with `FROM cdotyone/github-actions-runner:latest`.

You can contribute to this repository or create your own Docker image.

## 💡 Docker compose

### Simple runner

```yaml
version: '3'

services:

  runner:
    image: cdotyone/github-actions-runner:latest
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - /tmp:/tmp
    environment:
      - GH_REPOSITORY=xxxxxxxxxxxx
      - GH_RUNNER_TOKEN=xxxxxxxxxxxxx
      - GH_RUNNER_LABELS=node,golang,java,node \
    restart: unless-stopped
```

```sh
$ docker-compose up -d
```

### Concurrent executors

```sh
$ docker-compose scale runner=3
```

## 🤯 Advanced

### Run as root

For whatever (bad 😅) reason, if you need to start runners as root, you have to set container user to `root`, and add an empty `RUNNER_ALLOW_RUNASROOT` environment variables.

```

## ♻️  Host cleanup

Clean stopped containers on a daily basis:

```sh
$ crontab -e

0 0 * * * /usr/bin/docker system prune -f
```

## 🤝 Contributing

This project is open source and contributions from community (you!) are welcome.

There are many ways to contribute: writing code, documentation, reporting issues...

## Author

👤 [**Samuel Berthe**](https://github.com/samber)
👤 **Chris Doty** <modified by>

## 📝 License

Copyright © 2020 [Samuel Berthe](https://github.com/samber).

This project is [MIT](./LICENSE) licensed.
