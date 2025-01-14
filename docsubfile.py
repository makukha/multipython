from itertools import chain
import json
from subprocess import check_output
import sys
from urllib.request import urlopen

from cyclopts import App
from rich.console import Console
from rich.progress import track


app = App()

NS, REPO = 'makukha/multipython'.split('/')


@app.command
def image_digests():
    # get release tags
    data = json.loads(check_output(['docker', 'buildx', 'bake', '--print']))
    release = data['target']['base']['args']['RELEASE']
    tags = chain.from_iterable(
        [t.split(':')[-1] for t in target['tags'] if t.endswith(f'-{release}')]
        for target in data['target'].values()
    )
    # get digests
    BASE = 'https://hub.docker.com/v2'
    stdout = sys.stdout
    for tag in track(tuple(tags), console=Console(file=sys.stderr)):
        with urlopen(f'{BASE}/namespaces/{NS}/repositories/{REPO}/tags/{tag}') as f:
            info = json.load(f)
            stdout.write(f'| `{tag}` | `{info["digest"]}` |\n')


if __name__ == '__main__':
    app()
