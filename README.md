# Dockerized Python Homework

[![Python](https://img.shields.io/badge/Python-3.12-blue?logo=python&logoColor=white)](https://www.python.org/)
[![Docker](https://img.shields.io/badge/Docker-containerized-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![CI Tests](https://github.com/nikimono02/homework/actions/workflows/ci.yml/badge.svg?branch=prd)](https://github.com/nikimono02/homework/actions/workflows/ci.yml)

A small Python project that demonstrates how to package application logic in a
Docker image and run its tests inside the container. GitHub Actions builds the
same image and uses it to execute the test suite automatically.

## Table of Contents

1. [Features](#features)
2. [Prerequisites](#prerequisites)
3. [Quick Start with Docker](#quick-start-with-docker)
4. [Docker Commands](#docker-commands)
5. [Local Development](#local-development)
6. [Continuous Integration](#continuous-integration)
7. [Project Structure](#project-structure)
8. [Azure Terraform Query-to-CSV Demo](#azure-terraform-query-to-csv-demo)

## Features

- Simple addition logic written in Python
- Automated tests with pytest
- Reproducible Python 3.12 environment using Docker
- Docker-based test execution locally and in GitHub Actions

## Prerequisites

The recommended setup only requires:

- [Git](https://git-scm.com/)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) or another
  running Docker engine

Verify that Docker is installed and running:

```sh
docker --version
docker run --rm hello-world
```

## Quick Start with Docker

Clone the repository and enter the project directory:

```sh
git clone https://github.com/nikimono02/homework.git
cd homework
```

Build the image:

```sh
docker build -t homework .
```

Run the test suite:

```sh
docker run --rm homework
```

Expected result:

```text
1 passed
```

## Docker Commands

### Run the application

The image runs tests by default. Override its default command to execute the
application:

```sh
docker run --rm homework python sum.py
```

Expected output:

```text
2 + 2 = 4
```

### Run pytest explicitly

```sh
docker run --rm homework pytest -q test
```

### Rebuild after code changes

```sh
docker build -t homework .
docker run --rm homework
```

## Local Development

Docker is the recommended approach, but the project can also run with Python
3.12 installed locally:

```sh
python -m pip install -r requirements.txt
python sum.py
python -m pytest -q test
```

## Continuous Integration

The GitHub Actions workflow runs on pushes and pull requests for the protected
development flow. The CI test job:

1. Checks out the repository.
2. Builds the Docker image.
3. Starts the container, which runs pytest.

This verifies both the Docker build and the tests in the same environment.

## Azure Terraform Query-to-CSV Demo

This repo also includes a Terraform showcase under `terraform/`. It creates a
small Azure environment, runs an Azure Resource Graph query from a one-shot
Azure Container Instance, and stores the final query result as a CSV file in a
Storage Account blob container.

Create the demo after logging in with the Azure CLI:

```sh
az login
./scripts/apply_azure_demo.sh
```

Download the generated CSV:

```sh
./scripts/download_azure_demo_csv.sh
```

When you are ready to remove the Azure resources, use:

```sh
./scripts/destroy_azure_demo.sh
```

More details and customization options are in `terraform/README.md`.

## Project Structure

```text
.
|-- .github/workflows/
|   |-- ci.yml             # Docker-based test workflow
|   `-- pages.yml          # GitHub Pages deployment workflow
|-- test/
|   `-- test_sum.py        # Test suite
|-- terraform/             # Azure query-to-CSV Terraform demo
|-- scripts/               # Demo helper scripts
|-- .dockerignore          # Files excluded from the Docker build context
|-- .gitignore             # Files excluded from Git
|-- Dockerfile             # Python image and default test command
|-- pytest.ini             # Pytest configuration
|-- requirements.txt       # Python dependencies
|-- sum.py                 # Application logic
`-- README.md              # Project documentation
```
