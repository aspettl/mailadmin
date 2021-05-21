# Mailadmin

## Production deployment with Docker

Create a database user and an empty database. We use the docker image - inspect
its environment variables, which need to be customized. When the container starts,
it will automatically apply database migrations.

## User setup in production environment

To create a user, "docker exec" or "kubectl exec" into the container and run

```
bundle exec rails console
```

Then, use

```
User.create! do |u|
  u.email    = 'yourname@example.com'
  u.password = 'passwordwithatleast10chars'
end
```
