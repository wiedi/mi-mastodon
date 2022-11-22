# mi-mastodon

This is a work in progress.
The resulting image does not work out of the box and requires manual setup steps.

## Setup

After provisioning execute `/opt/mastodon/bin/mastodon-init.sh`.


For fresh installation create `/opt/mastodon/live/.env.production`, either by running

	RAILS_ENV=production bundle exec rake mastodon:setup

or manually.

If manually created run:

	RAILS_ENV=production bundle exec rails db:setup
	RAILS_ENV=production bundle exec rails assets:precompile


After that enable services:

	svcadm enable puma streamer sidekick:default
