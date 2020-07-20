mkdir -p ./docker-volume/traefik

curl https://raw.githubusercontent.com/chocobozzz/PeerTube/master/support/docker/production/config/traefik.toml > ./docker-volume/traefik/traefik.toml

touch ./docker-volume/traefik/acme.json

chmod 600 ./docker-volume/traefik/acme.json 

curl https://raw.githubusercontent.com/chocobozzz/PeerTube/master/support/docker/production/docker-compose.yml > docker-compose.yml 

curl https://raw.githubusercontent.com/Chocobozzz/PeerTube/master/support/docker/production/.env > .env
