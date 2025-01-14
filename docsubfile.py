from itertools import chain
import json
from pathlib import Path
from subprocess import DEVNULL, check_output
import sys
from typing import Literal, assert_never
from urllib.request import urlopen

from cyclopts import App  # type: ignore
from rich.console import Console  # type: ignore
from rich.progress import track  # type: ignore


app = App()

IMG = 'makukha/multipython'
INFO_DIR = Path('tests/share/info')
LATEST = '✨'


@app.command
def image_digests():
    # get release tags
    bake = check_output(['docker', 'buildx', 'bake', '--print'], stderr=DEVNULL)
    data = json.loads(bake)
    release = data['target']['base']['args']['RELEASE']
    tags = chain.from_iterable(
        [t.split(':')[-1] for t in target['tags'] if t.endswith(f'-{release}')]
        for target in data['target'].values()
    )
    # get digests
    NS, REPO = IMG.split('/')
    stdout = sys.stdout
    for tag in track(tuple(tags), console=Console(file=sys.stderr)):
        with urlopen(  # noqa: S310 = Audit URL open for permitted schemes
            f'https://hub.docker.com/v2/namespaces/{NS}/repositories/{REPO}/tags/{tag}'
        ) as f:
            info = json.load(f)
            stdout.write(f'| `{tag}` | `{info["digest"]}` |\n')


@app.command
def package_versions(group: Literal['base', 'derived', 'single'], /):
    def get_info(target: str) -> dict:
        return json.loads((INFO_DIR / f'{target}.json').read_text())

    bake = check_output(['docker', 'buildx', 'bake', '--print'], stderr=DEVNULL)
    data = json.loads(bake)
    out = sys.stdout

    # setup
    pkgs: tuple[str, ...]
    if group == 'base':
        targets = ['base']
        pkgs = ('pyenv', 'uv')
    elif group == 'derived':
        pkgs = ('pip', 'setuptools', 'tox', 'virtualenv')
        targets = [t for t in data['target'] if t != 'base' and not t.startswith('py')]
    elif group == 'single':
        pkgs = ('pip', 'setuptools', 'tox', 'virtualenv')
        targets = [t for t in data['target'] if t.startswith('py')]
        tags = [py['tag'] for py in get_info('unsafe')['python']]
        targets.sort(key=lambda x: tags.index(x))
    else:
        assert_never(group)

    # header
    out.write(f'| Image tag | {" | ".join(pkgs)} |\n')
    out.write(f'|---|{"---|" * len(pkgs)}\n')

    # body
    if group == 'base':
        info = get_info(targets[0])
        cells = ' | '.join(f'{info[p]["version"]} {LATEST}' for p in pkgs)
        out.write(f'| `{targets[0]}` | {cells} |\n')
        out.write(f'| *other images* | {cells} |\n')
    elif group == 'derived' or group == 'single':
        latest = get_info('latest')['system'][('packages')]
        mark = lambda p, v: f' {LATEST}' if latest[p] == v else ''  # noqa: E731 = lambda
        for target in targets:
            info = get_info(target)
            versions = {p: info['system']['packages'][p] for p in pkgs}
            cells = ' | '.join(f'{v}{mark(p, v)}' for p, v in versions.items())
            out.write(f'| `{target}` | {cells} |\n')
    else:
        assert_never(group)


if __name__ == '__main__':
    app()
