<!-- docsub: begin -->
<!-- docsub: include tests/test_readme_basic/tox.ini -->
<!-- docsub: lines after 2 upto -1 -->
```ini
# tox.ini
[tox]
env_list = py{27,35,36,37,38,39,310,311,312,313,314,313t,314t}
skip_missing_interpreters = false
[testenv]
command = {env_python} --version
```
<!-- docsub: end -->

```shell
docker run --rm -v .:/src -w /src makukha/multipython:unsafe tox run
```

Single version images can be used on their own:
```shell
$ docker run --rm -v .:/src -w /src makukha/multipython:py310 tox run
```
