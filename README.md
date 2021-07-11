# Mailadmin

Mailadmin is a simple tool to manage email domains, accounts and alias addresses
conveniently. It targets systems where there is only a handful of users who
want to manage their own domains. It is *not* meant to be used by end users
(those using the mailboxes) - however, there is an API for the Roundcube
password plugin.

It was developed to manage a mailserver running with
[docker-mailserver](https://github.com/docker-mailserver/docker-mailserver).

## Features

* UI features
  * manage domains and domain aliases
    * support domain catchalls
  * mailboxes for end users
    * `crypt`-based password hashes
    * optional email forwarding
  * alias addresses
  * blackhole addresses
* multiple "admin" users
  * one user can manage only his or her domains
* config export to `docker-mailserver`
* Roundcube password plugin API

:warning: This is an early release to make the project available and get some
feedback. And hopefully it is already of use to someone. Test coverage is
definitely still lacking, CI missing and docker images are not yet pushed to
a public repository.

### Screenshots

* [Manage Domains](./screenshots/manage_domains.png)
* [Manage Accounts](./screenshots/manage_accounts.png)

## Start/try out locally

Requirements:

* Ruby (see `.ruby-version`) and bundler for `bundle install` to
  install all dependencies.
* MariaDB or MySQL database server should be already running. The connection is
  established via the socket `/var/run/mysqld`. Expected user name is `mailadmin`,
  password empty, all privileges for `mailadmin_`-prefixed databases.

Create the database via `rails db:create`, `rails db:migrate` to
apply migrations, `rails db:fixtures:load` for some example data, `rails server`
to start and log in at http://localhost:3000 with "alice@example.com" and
password "test".

## Build docker images

Increase version number in `docker-compose.yml` and use `docker-compose build`.

## Local docker-based staging environment

Use `docker-compose up -d` and `docker-compose down`. Have a look at the
configuration in `docker-compose.yml` and the `Dockerfile` defaults for
environment variables.

Note: When the container starts, it will automatically apply database migrations.

## User setup in production environment

There is no UI to manage admin users.

To create a user, "docker exec" or "kubectl exec" into the container and run
`bundle exec rails console`. Then, use

```ruby
User.create! do |u|
  u.email    = 'yourname@example.com'
  u.password = 'passwordwithatleast10chars'
end
```

Note that every user is allowed to create new domains. There is only a check
that new subdomains must not belong to a domain of a different user.

## Integration into docker-mailserver

See `docker-compose.yml` and `integrations/docker-mailserver-configreload`.

## Integration into Roundcube

Roundcube will typically connect via IMAP to docker-mailserver and not need
any special configuration. The only exception is when Roundcube users should be
able to change their account passwords, see `integrations/roundcube-password-plugin`.
