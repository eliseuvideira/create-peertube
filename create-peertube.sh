#!/bin/bash

set -e

PROGNAME="${0##*/}"

usage () {
  echo "$PROGNAME: usage: $0 DOMAIN_URL ADMIN_EMAIL POSTGRES_USERNAME POSTGRES_PASSWORD" >&2
  echo "$PROGNAME: example: $0 videos.example.com admin@example.com postgres_username strong_password" >&2
}

exit_with_error () {
  echo "$PROGNAME: error: $1"
  exit 1
}

if (( $# != 4 )); then
  usage
  exit_with_error "invalid number of parameters"
  exit 1
fi

DOMAIN_URL=$1
ADMIN_EMAIL=$2
POSTGRES_USERNAME=$3
POSTGRES_PASSWORD=$4

get_domain () {
  sed 's/.*\.\(.*\..*\)/\1/' <<< $1
}

chmod 600 ./docker-volume/traefik/acme.json 

cat <<- __EOF__
POSTGRES_USER=$POSTGRES_USERNAME
POSTGRES_PASSWORD=$POSTGRES_PASSWORD
POSTGRES_DB=$POSTGRES_USERNAME
PEERTUBE_DB_USERNAME=$POSTGRES_USERNAME
PEERTUBE_DB_PASSWORD=$POSTGRES_PASSWORD
# PEERTUBE_DB_HOSTNAME is the Postgres service name in docker-compose.yml
PEERTUBE_DB_HOSTNAME=postgres
PEERTUBE_WEBSERVER_HOSTNAME=$DOMAIN_URL
PEERTUBE_WEBSERVER_PORT=443
PEERTUBE_WEBSERVER_HTTPS=true
# If you need more than one IP as trust_proxy
# pass them as a comma separated array:
PEERTUBE_TRUST_PROXY=["127.0.0.1", "loopback", "172.18.0.0/16"]
#PEERTUBE_SMTP_USERNAME=
#PEERTUBE_SMTP_PASSWORD=
PEERTUBE_SMTP_HOSTNAME=postfix
PEERTUBE_SMTP_PORT=25
PEERTUBE_SMTP_FROM=noreply@$(get_domain $DOMAIN_URL)
PEERTUBE_SMTP_TLS=false
PEERTUBE_SMTP_DISABLE_STARTTLS=false
PEERTUBE_ADMIN_EMAIL=$ADMIN_EMAIL
POSTFIX_myhostname=$DOMAIN_URL
# If you need to generate a list of sub/DOMAIN keys
# pass them as a whitespace separated string <DOMAIN>=<selector>
OPENDKIM_DOMAINS=$DOMAIN_URL=peertube
TRAEFIK_ACME_EMAIL=$ADMIN_EMAIL
# If you need to obtain ACME certificates for more than one DOMAIN
# pass them as a comma separated string
TRAEFIK_ACME_DOMAINS=$DOMAIN_URL
# /!\\ Prefer to use the PeerTube admin interface to set the following configurations /!\\
#PEERTUBE_SIGNUP_ENABLED=true
#PEERTUBE_TRANSCODING_ENABLED=true
#PEERTUBE_CONTACT_FORM_ENABLED=true
__EOF__
