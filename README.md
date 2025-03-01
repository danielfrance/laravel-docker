# Laravel Dockerized Development & Production Setup

This repository provides an opinionated Docker setup for Laravel applications, designed to work seamlessly across local development and production environments. The goal is to simplify Laravel deployments without relying on Laravel Sail, making the setup leaner, faster, and suitable for both bare-metal and containerized environments like Kubernetes (EKS/GKE).

This works well with my other repositories:

- [laravel-aws-iac](https://github.com/danielfrance/laravel-aws-iac)
- laravel-aws-kubernetes (Kubernetes Deployment -- coming soon)

## Overview

This setup includes:

Dockerfile for building production-ready images.
Docker Compose for spinning up local services.
Run Script (run.sh) to automate Laravel setup.
PostgreSQL & Redis preconfigured for Laravel.
Optimized for AWS/GCP & Kubernetes

## Getting Started

Prerequisites

- Docker
- Node.js & NPM (for frontend assets)

## Installation

1. Clone this repository into your existing Laravel project root

```
cd /path/to/your-laravel-project
git clone git@github.com:danielfrance/laravel-docker.git deploy
```

This will add the Dockerfile, docker-compose.yml, and run.sh to your project under a /deploy directory.

2. Move the necessary files to your project root

```
mv deploy/Dockerfile ./Dockerfile
mv deploy/docker-compose.yml ./docker-compose.yml
mv deploy/run.sh ./run.sh
chmod +x run.sh
```

The `run.sh` file has to be executable prior to copying the file to the container.
(If you want to keep the /deploy folder for versioning, feel free to adjust the paths in docker-compose.yml accordingly.)

3. Compare your `.env` with the `docker-compose.yml` file

There are several environment variables in the docker-compose file. Ensure that they are accurate, otherwise you may find connecting to the DB or Redis difficult.

4. Double check the docker-compose ports

You may want to double check the app, db, and redis ports in `docker-compose.yml` to ensure you're not stepping on any existing ports you have in use.

5. Start the app.

```
docker-compose up --build
```

6. Access the app

- Visit: http://localhost:8099
- Redis is available at: redis://localhost:63790
- PostgreSQL is available at: postgres://localhost:54329

## File Breakdown

#### Dockerfile 🐳

A production-ready Docker image optimized for Laravel.

- Uses PHP 8.3 with Apache.
- Installs required PHP extensions (pdo_pgsql, mbstring, etc.).
- Sets up Composer & Node.js.
- Ensures required Laravel directories (storage, cache) exist.
- Sets up Apache Virtual Hosts.

#### docker-compose.yml ⚙️

Defines local development services:

- laravel.app: Runs Laravel inside a container.
- pgsql: PostgreSQL database.
- redis: Redis instance.

#### run.sh 🚀

Handles Laravel setup when the container starts.

- Installs dependencies via Composer.
- Clears cache, views, and configs.
- Runs migrations and compiles assets.
- Starts Apache.

## Considerations

This containerization set up does not automatically start the queue or use Supervisor. This configuration is intended to use Kubernetes HPA and cron jobs to dynamically scale your workers.

## Troubleshooting

#### "run.sh: Permission Denied"

Issue: The entrypoint script lacks execute permissions and the local file may not have correct permissions

```
chmod +x run.sh
docker-compose up --build
```

#### "SQLSTATE[08006] could not translate host name ‘pgsql’"

Issue: Laravel can't resolve the database container.
Solution: Ensure `DB_HOST=pgsql` in `.env` (same as `docker-compose.yml`).

#### "Redis Not Connecting"

Issue: Redis might be misconfigured.
Solution:

- Ensure `REDIS_HOST=redis` in `.env`.
- Try `docker exec -it my_new_app-redis redis-cli ping` (should return PONG).

## Roadmap & Future Enhancements

1Harden Security

- Use non-root users in the Dockerfile.
- Apply read-only file permissions in production.

Optimize Build

- Use a multi-stage build to minimize image size.
- Consider php-fpm + Nginx for better performance.

Automate Deployments

- Integrate GitHub Actions for Docker builds.
- Push images to Amazon ECR/GCP Artifact Registry.

Kubernetes Integration

- Define Helm Charts for production Kubernetes deployments.
- Set up Horizontal Pod Autoscaling (HPA) for Laravel workers.

## Contributing

This is a work-in-progress opinionated Laravel setup. If you have suggestions or want to contribute, feel free to open a PR! 🚀

## License

This project is open-source and available under the MIT License.
