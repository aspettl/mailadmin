# Roundcube password plugin integration

The password plugin of Roundcube 1.5 supports an HTTP-based API for updating the password.

For details see https://github.com/roundcube/roundcubemail/tree/master/plugins/password.

## Required configuration

The following plugin options need to be set:

```php
$config['password_driver'] = 'httpapi';
$config['password_minimum_length'] = 10;
$config['password_httpapi_url'] = 'https://mailadmin.example.com/api/v1/roundcube_password';
```
