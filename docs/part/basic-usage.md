```shell
docker pull makukha/multipython@latest
```

<!-- docsub after line 2: cat tests/test_readme_basic/tox.ini -->
```ini
# tox.ini

```

```shell
docker run --rm -v .:/app makukha/multipython tox run --root /app
```

Single version images have tox installed and can be used standalone.
