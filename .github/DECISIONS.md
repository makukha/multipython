# Decisions registry

## Pyenv shims or manual symlinks?

Pyenv documents two separate ways to have multiple python versions on PATH:
1. Shims and `pyenv global`
2. Manually symlinking to `$(pyenv root)/versions/X.Y.Z/bin/python`

While shims also map `pip`, it seems to be impossible to have both GIL and free threaded versions on path. Also, manual symlinks provide more flexibility if it is neede to maintain more variations (e.g. optimizations).

Resolution: Use manual symlinks.
