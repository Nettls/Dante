FROM alpine:latest AS builder

# TODO: Various optional modules are currently disabled (see output of ./configure):
# - Libwrap is disabled because tcpd.h is missing.
# - BSD Auth is disabled because bsd_auth.h is missing.
# - ...

ARG DANTE_VERSION=1.4.3

RUN apk add --no-cache -t .build-deps \
        build-base \
        curl \
        linux-pam-dev

RUN cd /tmp &&\
    # https://www.inet.no/dante/download.html
    curl -L https://www.inet.no/dante/files/dante-${DANTE_VERSION}.tar.gz | tar -xz

RUN cd /tmp/dante-* &&\
    # See https://lists.alpinelinux.org/alpine-devel/3932.html
    ac_cv_func_sched_setscheduler=no ./configure &&\
    make install



FROM alpine:latest AS runtime

# Add an unprivileged user.
RUN apk add --no-cache \
        linux-pam \
        ca-certificates \
        &&\
    adduser -S -D -u 8062 -H sockd

# Default configuration
COPY etc/sockd.conf /etc/

# Files
COPY --from=builder /usr/local/bin/socksify /usr/local/bin/
COPY --from=builder /usr/local/sbin/sockd   /usr/local/sbin/
COPY usr/local/bin/entrypoint.sh /usr/local/bin/

ENTRYPOINT /bin/sh
CMD /usr/local/bin/entrypoint.sh
