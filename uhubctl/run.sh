#!/usr/bin/with-contenv bashio
set +eu

# Check if the log level configuration option exists
declare LOG_LEVEL="INFO"
if bashio::config.has_value 'LOG_LEVEL'; then
    LOG_LEVEL="$(bashio::string.lower "$(bashio::config 'LOG_LEVEL')")"
fi
bashio::log.blue "Log level is set to ${LOG_LEVEL}"

# Best-effort udev rules reload for environments where udev is available.
if command -v udevadm >/dev/null 2>&1; then
    bashio::log.blue "Reloading udev rules..."
    udevadm control --reload-rules || true
    udevadm trigger --subsystem-match=usb || true
    bashio::log.blue "Udev rules reloaded."
fi

while true
do
    bashio::log.blue "Starting MQTT - uhubctl bridge..."

    if ! bashio::services.available "mqtt"; then
        bashio::log.red "No MQTT service running! Retry after 30 seconds..."
    else
        export MQTT_HOST=$(bashio::services "mqtt" "host")
        export MQTT_PORT=$(bashio::services "mqtt" "port")
        export MQTT_USERNAME=$(bashio::services "mqtt" "username")
        export MQTT_PASSWORD=$(bashio::services "mqtt" "password")
        python3 main.py --log ${LOG_LEVEL}
    fi
    sleep 30
done
