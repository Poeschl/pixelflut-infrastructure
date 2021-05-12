FROM alpine:3.13.5 AS build

# Seperate layer with same packets as in final image to speed up build process
RUN apk add --no-cache numactl-dev sdl2-dev freetype-dev libvncserver-dev libc-dev
RUN apk add --no-cache git make gcc pkgconfig linux-headers && \
git clone https://github.com/tobleminer/shoreline && \
cd shoreline && \
make


FROM alpine:3.13.5

RUN apk add --no-cache numactl-dev sdl2-dev freetype-dev libvncserver-dev libc-dev
COPY --from=build /shoreline/shoreline /shoreline
COPY arial.ttf /
