# geo-service

The `geo-service` is a Go program that provides functionality to download and extract GeoIP database files from db-ip.com. It can run in both daemon mode (continuous) and one-time mode, allowing you to customize its behavior according to your needs.

The following databases are downloaded and extracted:
 - IP to Country Lite Database: [link](https://db-ip.com/db/download/ip-to-country-lite)
 - IP to City Lite Database: [link](https://db-ip.com/db/download/ip-to-city-lite)
 - IP to ASN Lite Database: [link](https://db-ip.com/db/download/ip-to-asn-lite)

Both CSV and MMDB formats are available.

## Table of Contents

- [Overview](#overview)
- [Configuration](#configuration)
  - [Environment Variables](#environment-variables)
  - [Command Line Flags](#command-line-flags)
- [Usage](#usage)
  - [Running in Daemon Mode](#running-in-daemon-mode)
  - [Running in One-Time Mode](#running-in-one-time-mode)
  - [Running in Kubernetes](#running-in-kubernetes)
- [License](#license)

## Overview

The `geo-service` program performs the following tasks:

1. Scrapes download links for GeoIP database files from [db-ip.com](https://db-ip.com).
2. Downloads and extracts the database files to a specified folder.
3. Optionally, it can run in daemon mode to continuously check for new updates.

## Configuration

### Environment Variables

You can configure the behavior of the program using environment variables with the `GEO_SERVICE` prefix. Here are the available environment variables:

- `GEO_SERVICE_INTERVAL`: Specifies the ticker interval in seconds for daemon mode (default: 10).
- `GEO_SERVICE_DOWNLOAD_FOLDER`: Sets the download folder path (default: "output").
- `GEO_SERVICE_DAEMON`: Controls whether the program runs in daemon mode (`true` or `false`, default: `false`).

### Command Line Flags

You can also pass configuration options via command-line flags:

- `--interval`: Specifies the ticker interval in seconds.
- `--download-folder`: Sets the download folder path.
- `--daemon`: Run the program in daemon mode (`true` or `false`).

## Usage

### Running in Daemon Mode

To run the `geo-service` program in daemon mode, use the following command:

```bash
./geo-service --daemon=true
```

This will continuously check for new GeoIP database updates at the specified interval.

### Running in One-Time Mode
To run the geo-service program in one-time mode (to download and extract database files once), use the following command:

```bash
./geo-service
```

This will perform a one-time download and extraction of the database files.

### Running in Kubernetes

In this section, we will discuss how to deploy your application in Kubernetes using both a CronJob or a Deployment.

**Using CronJob**

A CronJob is used to run tasks on a schedule, similar to a cron job in a Unix-like environment. In Kubernetes, you can use a CronJob to schedule periodic tasks, such as batch jobs, backups, or data processing.

To deploy your application using a CronJob, modify the example [cronjob manifest](kubernetes/cronjob.yaml) and apply:

```bash
kubectl apply -f kubernetes/cronjob.yaml
```

**Using Deployment**

A Deployment in Kubernetes is used for deploying and managing long-running applications, ensuring they are always available.

To deploy your application using a Deployment, modify the example [deployment manifest](kubernetes/deployment.yaml) and apply:

```bash
kubectl apply -f kubernetes/deployment.yaml
```
