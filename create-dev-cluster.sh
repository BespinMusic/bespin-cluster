export SECRET_KEY_BASE=dev-key
export MYSQL_DATABASE=authn

export APP_DB_NAME=bespin
export APP_DB_USERNAME=postgres
export APP_DB_PASSWORD=test

docker-compose up -d --build
