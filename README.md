# pdfglue

Append several PDF files together. I needed to do it one day but didn't want to use any obscure "free" service online. 

This app is just an interface to use ghostscript CLI that you can run locally.

## Development

Create the database, bundle install, migrate and run the application:

```shell
$ docker run --name pdfglue-postgres -e POSTGRES_PASSWORD=pdfglue_development_password -p 5432:5432 -d postgres
$ bundle install
$ yarn install --check-files
$ rails db:migrate
$ rails s -b 0.0.0.0
```

## Production

Create the `docker-compose.yml` file:

```yml
version: '2'

services: 
    rails:
        image: nu12/pdfglue
        ports: 
            - "80:3000"
        links:
            - "database"
        environment: 
            POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
            
        restart: unless-stopped
    database:
        image: postgres:13.1-alpine
        restart: unless-stopped
        environment: 
            POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
```

Run: 

```shell
$ POSTGRES_PASSWORD=your-password docker-compose up
```

Note: you can use the `docker-compose.yml` file from the repository if you've cloned it.

## Manual build

```shell
$ docker build --build-arg RAILS_MASTER_KEY=master-key-here -t nu12/pdfglue .
```