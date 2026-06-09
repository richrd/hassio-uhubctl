ARG BUILD_FROM=ghcr.io/hassio-addons/base:20.1.1
FROM ${BUILD_FROM}

RUN \
    set -x \
    && apk add --no-cache --virtual .build-dependencies \
        build-base \
        linux-headers \
	libusb-dev \
	git \
	python3 \
    py3-pip \
    eudev

RUN mkdir -p /etc/udev/rules.d && cat <<'EOF' > /etc/udev/rules.d/52-uhubctl.rules
SUBSYSTEM=="usb", DRIVER=="hub|usb", MODE="0666"
# Linux 6.0 or later (it is ok to have this block present for older Linux kernels):
SUBSYSTEM=="usb", DRIVER=="hub|usb", \
  RUN+="/bin/sh -c 'chmod -f 666 /sys$devpath/*port*/disable || true'"
EOF

RUN git clone https://github.com/mvp/uhubctl.git /tmp/uhubctl && \
    cd /tmp/uhubctl && make && make install

COPY . /app
WORKDIR /app
RUN pip3 install -r requirements.txt

RUN chmod a+x run.sh

CMD ["/app/run.sh"]
