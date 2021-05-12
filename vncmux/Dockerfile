FROM alpine:3.13.5 AS build

# Seperate layer with same packets as in final image to speed up build process
RUN apk add --no-cache libvncserver-dev libc-dev
RUN apk add --no-cache git make gcc && \
git clone https://github.com/tobleminer/vncmux && \
cd vncmux && \
make


FROM alpine:3.13.5

RUN apk add --no-cache libvncserver-dev libc-dev
COPY --from=build /vncmux/vncmux /vncmux
