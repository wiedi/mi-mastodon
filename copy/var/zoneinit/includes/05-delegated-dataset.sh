#!/bin/bash
UUID=$(mdata-get sdc:uuid)
DDS=zones/${UUID}/data

if zfs list ${DDS} 1>/dev/null 2>&1; then
	zfs create ${DDS}/pgsql || true
	zfs create ${DDS}/redis || true
	zfs create ${DDS}/conf || true
	zfs create ${DDS}/public || true

	if ! zfs get -o value -H mountpoint ${DDS}/pgsql | grep -q /var/pgsql; then
		zfs set compression=lz4 ${DDS}/pgsql
		zfs set mountpoint=/var/pgsql ${DDS}/pgsql
		chown postgres:postgres /var/pgsql
	fi

	if ! zfs get -o value -H mountpoint ${DDS}/redis | grep -q /var/db/redis/; then
		zfs set mountpoint=/var/db/redis/ ${DDS}/redis
		chown redis:redis /var/db/redis/
	fi

	if ! zfs get -o value -H mountpoint ${DDS}/conf | grep -q /opt/mastodon/conf; then
		zfs set mountpoint=/opt/mastodon/conf ${DDS}/conf
		chown -R mastodon:mastodon /opt/mastodon/conf
	fi
	ln -s /opt/mastodon/conf/.env.production /opt/mastodon/live/.env.production

	if ! zfs get -o value -H mountpoint ${DDS}/public | grep -q /opt/mastodon/live/public/system; then
		zfs set mountpoint=/opt/mastodon/live/public/system ${DDS}/public
		chown -R mastodon:mastodon /opt/mastodon/live/public/system
	fi
	
fi
