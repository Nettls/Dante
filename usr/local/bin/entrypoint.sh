#!/bin/sh

if [[ ! -z "$SOCKD_CONF" ]]
then
    echo -n "SOCKD_CONF environment variable provided, provisioning configuration..."
    cat > /etc/sockd.conf <<EOF
$SOCKD_CONF
EOF
    echo " done"
    # Add "foreground = yes" parameter anyway
    #sed -i "s/^[[:blank:]]*foreground.*$/foreground = yes/" /etc/stunnel/stunnel.conf
else
    echo "SOCKD_CONF environment variable is not provided, using existing configuration at /etc/sockd.conf ."
fi

sockd
