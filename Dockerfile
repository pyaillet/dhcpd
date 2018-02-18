FROM alpine:3.7 AS mirror
RUN mkdir -p /out/etc/apk && cp -r /etc/apk/* /out/etc/apk/
RUN apk update
RUN apk add --no-cache --initdb -p /out \
    alpine-baselayout \
    busybox \
    dhcp \
    musl
RUN mkdir -p /out/var/lib/dhcp/

# Remove apk residuals
RUN rm -rf /out/etc/apk /out/lib/apk /out/var/cache
RUN touch /out/var/lib/dhcp/dhcpd.leases

FROM scratch
ENTRYPOINT []
CMD []
WORKDIR /
COPY --from=mirror /out/ /
COPY /dhcpd.conf /
ENTRYPOINT ["/usr/sbin/dhcpd", "-f", "-cf", "/dhcpd.conf", "--no-pid"]
LABEL org.mobyproject.config='{"binds": ["/run/resolvconf:/etc"], "capabilities": ["CAP_NET_ADMIN", "CAP_NET_BIND_SERVICE", "CAP_NET_RAW", "CAP_SYS_ADMIN"]}'

