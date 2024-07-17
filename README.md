# Backurr

Docker containers for rr backup to remote.

Heavily inspired at [vaultwarden-backup](https://github.com/ttionya/vaultwarden-backup)

## Usage

### Configure Rclone (⚠️ MUST READ ⚠️)

> **For backup, you need to configure Rclone first, otherwise the backup tool will not work.**
> 
> **For restore, it is not necessary.**

We upload the backup files to the storage system by [Rclone](https://rclone.org/).

Visit [GitHub](https://github.com/rclone/rclone) for more storage system tutorials. Different systems get tokens differently.

#### Configure and Check

You can get the token by the following command.

```shell
docker run --rm -it \
  --mount type=volume,source=backurr-rclone-data,target=/config/ \
  rodriguestiago0/backurr:latest \
  rclone config
```

**We recommend setting the remote name to `Backurr`, otherwise you need to specify the environment variable `RCLONE_REMOTE_NAME` as the remote name you set.**

After setting, check the configuration content by the following command.

```shell
docker run --rm -it \
  --mount type=volume,source=backurr-rclone-data,target=/config/ \
  rodriguestiago0/backurr:latest \
  rclone config show

# Microsoft Onedrive Example
# [Backurr]
# type = onedrive
# token = {"access_token":"access token","token_type":"token type","refresh_token":"refresh token","expiry":"expiry time"}
# drive_id = driveid
# drive_type = personal
```

<br>


### Backup

#### Use Docker Compose (Recommend)

Download `docker-compose.yml` to you machine, edit environment variables and start it.

You need to go to the directory where the `docker-compose.yml` file is saved.

```shell
# Start
docker-compose up -d

# Stop
docker-compose stop

# Restart
docker-compose restart

# Remove
docker-compose down
```

#### Automatic Backups

Start the backup container with default settings. (automatic backup at 12AM every day)

```shell
docker run -d \
  --restart=always \
  --name backurr \
  --mount type=volume,source=backurr-rclone-data,target=/config/ \
  rodriguestiago0/backurr:latest
```

<br>

## Environment Variables

> **Note:** All environment variables have default values, you can use the docker image without setting any environment variables.

#### RCLONE_REMOTE_NAME

The name of the Rclone remote, which needs to be consistent with the remote name in the rclone config.

You can view the current remote name with the following command.

```shell
docker run --rm -it \
  --mount type=volume,source=backurr-rclone-data,target=/config/ \
  rodriguestiago0/backurr:latest \
  rclone config show

# [Backurr] <- this
# ...
```

Default: `Backurr`

#### RCLONE_REMOTE_DIR

The folder where backup files are stored in the storage system.

Default: `/Backurr/`

#### RCLONE_GLOBAL_FLAG

Rclone global flags, see [flags](https://rclone.org/flags/).

**Do not add flags that will change the output, such as `-P`, which will affect the deletion of outdated backup files.**

Default: `''`

#### CRON

Schedule to run the backup script, based on [`supercronic`](https://github.com/aptible/supercronic). You can test the rules [here](https://crontab.guru/#0_0_*_*_*).

Default: `0 0 * * *` (run the script at 12AM every day)


#### BACKUP_KEEP_DAYS

Only keep last a few days backup files in the storage system. Set to `0` to keep all backup files.

Default: `0`

#### TIMEZONE

Set your timezone name.

Here is timezone list at [wikipedia](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones).

Default: `UTC`

<br>

## Using `.env` file

If you prefer using an env file instead of environment variables, you can map the env file containing the environment variables to the `/.env` file in the container.

```shell
docker run -d \
  --mount type=bind,source=/path/to/env,target=/.env \
  rodriguestiago0/backurr:latest
```

<br>

## About Priority

We will use the environment variables first, followed by the contents of the file ending in `_FILE` as defined by the environment variables. Next, we will use the contents of the file ending in `_FILE` as defined in the `.env` file, and finally the values from the `.env` file itself.

<br>



## Advance

- [Multiple remote destinations](docs/multiple-remote-destinations.md)
- [Manually trigger a backup](docs/manually-trigger-a-backup.md)

<br>

## License

MIT
