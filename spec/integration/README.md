## Integration tests

The specs in this directory expect a working Rexster server. The easiest way
to get one is to download rexster from
https://github.com/tinkerpop/rexster/wiki/Downloads
and run a local server with `bin/rexster.sh -s`.

If you would rather run against an existing server you can do so by setting the
`REXPRO_HOST` and/or `REXPRO_PORT` env vars, e.g.:

```
REXPRO_HOST=rexster-server bundle exec rake integration_tests
```