# Janus Docker Plus

A Docker image for [Janus WebRTC Gateway](https://github.com/meetecho/janus-gateway) with the [janus-telephony-kit](https://github.com/megafarad/janus-telephony-kit) plugin included.

## Overview

This Docker image provides a production-ready deployment of Janus Gateway v1.3.3 with telephony capabilities. It's built on Ubuntu and includes all necessary dependencies for WebRTC communication and telephony integration.

## Features

- **Janus Gateway v1.3.3** - Stable WebRTC server implementation
- **Janus Telephony Kit Plugin** - Telephony integration capabilities
- **Multi-stage Docker build** - Optimized image size
- **Configurable API security** - Support for API secret configuration
- **Comprehensive port exposure** - All necessary Janus ports pre-configured

## Quick Start

### Pull from Docker Hub

```bash
docker pull sirhc77/janus-plus
```


### Run the Container

Basic usage:

```shell script
docker run -d \
  -p 8088:8088 \
  -p 8188:8188 \
  -p 10000-10200:10000-10200/udp \
  sirhc77/janus-plus
```


With API secret:

```shell script
docker run -d \
  -p 8088:8088 \
  -p 8188:8188 \
  -p 10000-10200:10000-10200/udp \
  -e API_SECRET=your-secret-here \
  sirhc77/janus-plus
```


## Configuration

### Environment Variables

- `API_SECRET` - (Optional) Set an API secret for securing Janus REST API access

### Exposed Ports

| Port Range | Protocol | Description             |
|------------|----------|-------------------------|
| 10000-10200 | UDP | RTP/RTCP media ports    |
| 8188 | TCP | WebSocket server        |
| 8088 | TCP | HTTP REST API           |
| 8089 | TCP | HTTPS REST API          |
| 8889 | TCP | Secure WebSocket server |
| 8000 | TCP | Admin/Monitor HTTP      |
| 7088 | TCP | Admin/Monitor plaintext |
| 7089 | TCP | Admin/Monitor secure    |

## Building from Source

Clone the repository and build the image:

```shell script
git clone <repository-url>
cd janus-docker-plus
docker build -t janus-plus .
```


## Docker Compose Example

```yaml
version: '3.8'

services:
  janus:
    image: sirhc77/janus-plus
    ports:
      - "8088:8088"
      - "8188:8188"
      - "10000-10200:10000-10200/udp"
    environment:
      - API_SECRET=your-secret-here
    restart: unless-stopped
```


## Dependencies

The image includes the following key dependencies:

- libnice (ICE/STUN/TURN)
- libsrtp2 (Secure RTP)
- usrsctp (SCTP for DataChannels)
- libwebsockets (WebSocket support)
- Sofia SIP (SIP protocol support)
- Various codec libraries (Opus, Ogg)

## License

This project packages open-source software. Please refer to the individual projects for their respective licenses:

- [Janus Gateway](https://github.com/meetecho/janus-gateway)
- [Janus Telephony Kit](https://github.com/megafarad/janus-telephony-kit)

As for the Docker file and startup script, they are released under the GPL-2.0 License.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## Automated Builds

This image is automatically built and published to Docker Hub on release using GitHub Actions.
