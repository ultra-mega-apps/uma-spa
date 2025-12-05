[![docker pull socialengine/nginx-spa][image shield]][docker hub]

This is a Docker image used to serve a Single Page App (pure frontend javascript) using nginx, it support PushState, and includes a way to pass configuration at run time.

## Supported tags and `Dockerfile` links

- [`latest` (_Dockerfile_)][latest]

## Included on top of [base][base image] nginx image

- [pushState][push state] support. Every request is routed to `/app/index.html`. Useful for the clean urls (no `!#`)
- [ENV-based Config](#env-config)

# App Setup

This docker image is built for `index.html` file being in the `/app` directory. `pushState` is enabled.

At a minimum, you will want this in your `Dockerfile`:

```Dockerfile
FROM socialengine/nginx-spa

COPY build/ /app
COPY index.html /app/index.html
```

Then you can build & run your app in the docker container. It will be served by a nginx static server.

```bash
$ docker build -t your-app-image .
$ docker run -e API_KEY=yourkey -e API_URL=http://myapi.example.com \
  -e CONFIG_VARS=API_URL,API_KEY -p 8000:80 your-app-image
```

You can then go to `http://docker-ip:8000/` to see it in action.

## Env Config

Included is ability to pass `run` time environmental variables to your app.

This is very useful in case your API is on a different domain, or if you want to configure central error logging.

```bash
$ docker run -e RAVEN_DSN=yourkey -e API_URL=http://myapi.example.com  \
  -e CONFIG_VARS=API_URL,RAVEN_DSN -p 8000:80 umapps/spa:1.0.0
 ==> Writing /app/config.js with {"RAVEN_DSN":"yourkey", "API_URL":"http://myapi.example.com"}
```

This will create a `config.js` file, which you can then add to your index.html, or load asynchronously. The path can be controlled with `CONFIG_FILE_PATH` environmental variable.

## Multi-Platform Support (json_env removed)

To support multiple platforms (e.g., linux/amd64 and linux/arm64) without relying on an external architecture-specific binary, we removed the `json_env` dependency and replaced it with a small, portable Bash implementation inside `start-container.sh`.

What changed:

- At build time, we no longer download `json_env`.
- At runtime, `start-container.sh` reads the names from `CONFIG_VARS`, pulls their values from the environment, safely escapes them, and generates `/app/config.js` with `window.__env = { ... }`.

Why this helps:

- Works uniformly across amd64 and arm64 (no arch-specific binary).
- No network fetch during image build; faster and more reproducible builds.

Usage remains the same:

```bash
$ docker run -e API_URL=http://myapi.example.com -e API_KEY=secret \
  -e CONFIG_VARS=API_URL,API_KEY -p 8000:80 your-app-image
 ==> Writing /app/config.js with {"API_URL":"http://myapi.example.com", "API_KEY":"secret"}
```

Notes:

- All values are written as strings into `window.__env`.
- You can change the target path with `CONFIG_FILE_PATH` (defaults to `/app`).
- The compose file can declare multiple platforms (e.g., `linux/amd64`, `linux/arm64`) and this image will work without additional changes.

[push state]: https://developer.mozilla.org/en-US/docs/Web/API/History_API
[latest]: https://github.com/SocialEngine/docker-nginx-spa/blob/master/Dockerfile
[base image]: https://github.com/nginxinc/docker-nginx
[image shield]: https://img.shields.io/badge/dockerhub-socialengine%2Fnginx--spa-blue.svg
[docker hub]: https://registry.hub.docker.com/u/socialengine/nginx-spa/
