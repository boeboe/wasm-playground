# geo-service

The `geo-service` is a Go program that provides functionality to download and extract GeoIP database files from db-ip.com. It can run in both daemon mode (continuous) and one-time mode, allowing you to customize its behavior according to your needs.

## Table of Contents

- [Overview](#overview)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Environment Variables](#environment-variables)
  - [Command Line Flags](#command-line-flags)
- [Usage](#usage)
  - [Running in Daemon Mode](#running-in-daemon-mode)
  - [Running in One-Time Mode](#running-in-one-time-mode)
- [Configuration](#configuration)
- [License](#license)

## Overview

The `geo-service` program performs the following tasks:

1. Scrapes download links for GeoIP database files from [db-ip.com](https://db-ip.com).
2. Downloads and extracts the database files to a specified folder.
3. Optionally, it can run in daemon mode to continuously check for new updates.

## Getting Started

### Prerequisites

Before using the `geo-service` program, make sure you have the following prerequisites:

- Go programming language installed on your system.

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

## Configuration
You can customize the program's behavior by setting environment variables or using command-line flags as mentioned in the Environment Variables and Command Line Flags sections.

## License
This project is licensed under the MIT License - see the LICENSE file for details.
