#!/bin/sh

sudo -u mastodon bash -c "
 cd /opt/mastodon/live
 export TMPDIR=/var/tmp
 bundle config deployment 'true'
 bundle config without 'development test'
 bundle install
 yarn install --pure-lockfile
"

# hacks
# see https://smartos.topicbox.com/groups/smartos-discuss/T039f2e74b8897c3f-Md73dcac30e3de34069ffc7a5

find /opt/mastodon/live/ -name hiredis_ext.so -print -delete

ed -s /opt/mastodon/live/config/database.yml  << 'EOF'
1
a
  gssencmode: 'disable'
.
w
q
EOF

# see https://github.com/Gargron/blurhash/pull/18
gsed -i 's/u_int8_t/uint8/' /opt/mastodon/live/vendor/bundle/ruby/3.0.0/gems/blurhash-0.1.6/lib/blurhash.rb