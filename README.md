# FastAPI + Redis Platform

**Author:** Farid Arjmandmanesh  
**Date:** 2025-08-16

[![Build Status](https://gitlab.com/<your-username>/<your-repo>/badges/main/pipeline.svg)](https://gitlab.com/<your-username>/<your-repo>/pipelines)

---

## Table of Contents

- [Project Overview](#project-overview)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Setup & Installation](#setup--installation)
- [Usage](#usage)
- [CI/CD Pipeline](#cicd-pipeline)
- [Logging](#logging)
- [Folder Structure](#folder-structure)
- [License](#license)

---

## Project Overview

This is a **FastAPI** application that interacts with **Redis** to store and retrieve key-value pairs. The project is containerized using **Docker** and orchestrated with **Docker Compose**, following DevOps best practices:

- Optimized Docker image
- Environment variable management
- Fault-tolerant Docker Compose setup
- CI/CD pipeline via **GitLab**

---

## Features

- **GET /**: Fetch the value of a predefined key in Redis
- **POST /write/{key}**: Write a key-value pair to Redis
- Optimized Docker setup
- Redis persistence with Docker volumes
- Structured logging for all key operations

---

## Prerequisites

- [Docker](https://www.docker.com/) >= 20.x
- [Docker Compose](https://docs.docker.com/compose/) >= 1.29.x
- Python >= 3.9 (for local dev)
- GitLab account (for CI/CD)

---

## Setup & Installation

1. **Clone the repository**

```bash
git clone https://gitlab.com/<your-username>/<your-repo>.git
cd <project-folder>
```

2. **Create .env file**

```bash
cp .env.example .env
```

Update .env variables if necessary.

3. **Start services**

```bash
docker-compose up --build
```

• FastAPI available at http://localhost:8000
• Redis available at localhost:6379

4. **Stop services**

```bash
docker-compose down
```

5. **Optional: Run in detached mode**

```bash
docker-compose up -d
```

6. **View logs**

```bash
docker-compose logs -f
```

---

## Usage

• Write a key-value pair:

```bash
curl -X POST "http://localhost:8000/write/mykey" -d "value=hello"
```

• Read a key:

```bash
curl "http://localhost:8000/"
```

---

## CI/CD Pipeline

    •	.gitlab-ci.yml stages:
    1.	Build: Builds Docker image for the app
    2.	Test: Runs unit tests using Redis service
    3.	Deploy: Pushes Docker image to GitLab Container Registry
    •	Redis service available during tests to ensure integration works.
    •	Linting and static code checks can be added to the pipeline.
    •	Pipeline badge at the top shows build status.

Example pipeline snippet:

```yaml
stages:
  - build
  - test
  - deploy
```

    •	Can be expanded to deploy automatically to staging or production servers.

---

## Logging

    •	Uses Python logging module.
    •	Logs captured:
    •	Application startup and shutdown
    •	Redis key operations
    •	Errors and warnings
    •	Logs can be forwarded to centralized logging systems like ELK or Grafana Loki.
    •	Structured logging improves observability and debugging.

---

## Folder Structure

```text
.
├── Dockerfile
├── docker-compose.yml
├── .gitlab-ci.yml
├── .dockerignore
├── .gitignore
├── .env
├── README.md
├── main.py
├── requirements.txt
└── .vscode/
    ├── settings.json
    ├── launch.json
    └── tasks.json
```
