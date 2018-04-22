#! /usr/bin/env bash


# Build modules from source.
if [ -d "${DATADIR}/modules" ]; then
  # Store current directory.
  cwd="$(pwd)"

  # Find module sources.
  modules=$(find "${DATADIR}/modules" -name "*.cpp")

  # Build modules.
  for module in $modules; do
    echo "Building module $module..."
    cd "$(dirname "$module")"
    znc-buildmod "$module"
  done

  # Go back to original directory.
  cd "$cwd"
fi

# Create default config if it does not exist
if [ ! -f "${DATADIR}/configs/znc.conf" ]; then
  echo "Creating a default znc configuration..."
  mkdir -p "${DATADIR}/configs"
  cp /znc.conf.default "${DATADIR}/configs/znc.conf"
fi

# Create default saslauthd config if it does not exist
if [ ! -f "${DATADIR}/saslauthd.conf" ]; then
  echo "Creating a default saslauthd configuration..."
  cp /saslauthd.conf.default "${DATADIR}/saslauthd.conf"
fi

# Create default certificate if it does not exist
if [ ! -f "${DATADIR}/znc.pem" ]; then
  echo "Creating a default znc certificate..."
  openssl req -nodes -newkey rsa:2048 -keyout ${DATADIR}/znc.pem -subj "/CN=${SSL_DOMAIN}" -x509 -days 3650 -out ${DATADIR}/znc.pem
fi



# Make sure $DATADIR is owned by znc user. This effects ownership of the
# mounted directory on the host machine too.
echo "Setting necessary permissions..."
chown -R znc:znc "$DATADIR"

# Start ZNC.
echo "Starting ZNC..."
# exec sudo -u znc znc --foreground --datadir="$DATADIR" $@
# exec /bin/bash
exec /usr/bin/supervisord -c /supervisord.conf

