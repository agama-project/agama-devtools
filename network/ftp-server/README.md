# FTP Server

This documentation describes configuring a testing FTP server. There are several
FTP servers available, this document describes the
[vsftpd](https://security.appspot.com/vsftpd.html) server.

## Installation

Install the `vsftpd` package: `sudo zypper install vsftpd`

## Firewall

If you are using firewall then make sure the firewall ports are open:

- `firewall-cmd --zone=public --add-service=ftp` - open the main FTP port in the
  currently running firewall
- `firewall-cmd --add-port=30000-30100/tcp` - open the ports for passive
  connections (this is the range configured in the default configuration file,
  see the `pasv_max_port` and `pasv_min_port` values there)
- If everything works fine you can either run the same commands with the
  `--permanent` parameter or run `firewall-cmd --runtime-to-permanent` to apply
  this configuration automatically after reboot.

## Configuration

The configuration is located in the `/etc/vsftpd.conf` file. For more details
about the configuration options see [man
vsftpd.conf](https://linux.die.net/man/5/vsftpd.conf).

In most cases you do not need to change anything, the anonymous access is
enabled by default and the files are served from the `/srv/ftp` directory.

The password protected access works by default too, use any user credentials for
logging in. By default the server serves the content of the user's home
directory. If you want to serve the same content as for the anonymous access for
all users then set the `local_root=/srv/ftp` option in the configuration file.

If you are testing password protected access then you might want to disable
anonymous access to be sure it is not used accidentally. You can do that with
setting the `anonymous_enable=NO` configuration option.

> [!NOTE]
>
> You can configure the server also by using the obsolete YaST ftp-server
> module. Just be careful that by default YaST configures only maximum 3
> connections from the same IP. The newer libzypp in SLE/Leap 16.1 or in
> openSUSE Tumbleweed uses parallel download with multiple connections exceeding
> this limit. The download then might fail with an error.
>
> Either increase the limit to 10 or so or set it to 0 for unlimited
> connections. Or delete the `max_per_ip` option in the configuration file, the
> default is unlimited number of connections when not set.

## Starting the server

- Start the server with `sudo systemctl start vsftpd.service`
- If you want to automatically start it after boot: `sudo systemctl enable
  vsftpd.service`
- Alternatively you can use the `vsftpd.socket` service instead. That will start
  the server automatically when receiving a request. After processing the
  request the server exits. This might be useful if the server is needed only
  rarely, for heavy loads it is better to keep it always running.

## Installation server

To serve RPM packages to install just copy them into the `/srv/ftp` directory.
If you want to serve several products you can create a structure like
`/srv/ftp/leap/16.0` or something like that.

If you have a full installation ISO downloaded then you can mount it to save
some disk space:

```sh
sudo mount Leap-16.0-offline-installer-x86_64.install.iso /srv/ftp/leap/16.0
```

> [!NOTE]
>
> The packages on the full installation medium are located in the `install/`
> subdirectory, do not forget to append this path to the installation URL.
