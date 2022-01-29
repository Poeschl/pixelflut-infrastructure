FROM alpine:3.15 AS build

# Seperate layer with same packets as in final image to speed up build process
RUN apk add --no-cache \
    libvncserver-dev=0.9.13-r2 \
    libc-dev=0.7.2-r3
RUN apk add --no-cache \
    build-base=0.5-r2 \
    git=2.34.1-r0 \
    ca-certificates=20211220-r0 \
    && \
    git clone https://github.com/tobleminer/vncmux && \
    cd vncmux && \
    make


FROM alpine:3.15

RUN apk add --no-cache \
    libvncserver-dev=0.9.13-r2 \
    libc-dev=0.7.2-r3

ENTRYPOINT ["vncmux"]

COPY --from=build /vncmux/vncmux /usr/local/bin/vncmux
