#!/bin/bash
LC_ALL=en_US.UTF-8

PGDATA='/var/pgsql/data'

# Create only if not existing yet
if [ ! -d ${PGDATA} ]; then
	mkdir -p ${PGDATA}
	chown postgres:postgres ${PGDATA}
	su postgres -c 'initdb -E UTF8 -D /var/pgsql/data/'
fi

# tuned for ~4gb
gsed -i \
 -e "s/max_connections = .*/max_connections = 200/" \
 -e "s/shared_buffers = .*/shared_buffers = 1GB/" \
 -e "s/#*maintenance_work_mem = .*/maintenance_work_mem = 256MB/" \
 -e "s/#*work_mem = .*/work_mem = 1310kB/" \
 -e "s/#*effective_cache_size = .*/effective_cache_size = 3GB/" \
 -e "s/#*checkpoint_completion_target = .*/checkpoint_completion_target = 0.9/" \
 /var/pgsql/data/postgresql.conf


svcadm enable -s svc:/pkgsrc/postgresql:default

log "waiting for the socket to show up"
COUNT="0";
while ! ls /tmp/.s.PGSQL.* >/dev/null 2>&1; do
	sleep 1
	((COUNT=COUNT+1))
	if [[ $COUNT -eq 60 ]]; then
		log "ERROR Could not talk to PGSQL after 60 seconds"
		ERROR=yes
		break 1
	fi
done
[[ -n "${ERROR}" ]] && exit 31
log "(it took ${COUNT} seconds to start properly)"


echo "CREATE USER mastodon WITH CREATEDB PASSWORD 'mastodon';" | sudo -u postgres PGPASSWORD=postgres psql || true