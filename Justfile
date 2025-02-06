default:
    @just --list

img := "makukha/multipython"

# helpers
git-head := "$(git rev-parse --abbrev-ref HEAD)"
gh-issue := "$(git rev-parse --abbrev-ref HEAD | cut -d- -f1)"
gh-title := "$(GH_PAGER=cat gh issue view " + gh-issue + " --json title -t '{{.title}}')"
version := "$(uv run bump-my-version show current_version 2>/dev/null)"

# init local dev environment
[group('dev')]
[macos]
init:
    #!/usr/bin/env bash
    set -euo pipefail
    sudo port install gh hadolint jq shellcheck uv yq
    cat <<EOF | xargs -n1 uv tool install -U
      git+https://github.com/makukha/bump-my-version@date62
      docsub
      mypy
      ruff
      towncrier
    EOF
    # pre-commit hook
    echo -e "#!/usr/bin/env bash\njust pre-commit" > .git/hooks/pre-commit
    chmod a+x .git/hooks/pre-commit

# check for version updates
[group('dev')]
checkupd:
    docker run --rm -t {{img}}:base py checkupd

# add news item of type
[group('dev')]
news type issue *msg:
    #!/usr/bin/env bash
    set -euo pipefail
    issue="{{ if issue == "-" { gh-issue } else { issue } }}"
    msg="{{ if msg == "" { gh-title } else { msg } }}"
    uvx towncrier create -c "$msg" "$issue.{{type}}.md"

# run linters
[group('dev')]
lint:
    # docker and scripts
    hadolint Dockerfile
    shellcheck bin/**/*.sh tests/share/*.sh
    # docsubfile
    uvx mypy docsubfile.py
    uvx ruff check
    uvx ruff format --check

# prune local tags, images, and build cache
[group('dev')]
clean:
    #!/usr/bin/env bash
    set -euo pipefail
    docker image rm "{{img}}" || true
    docker image ls --format json | \
      jq -r '. | select(.Repository == "{{img}}") | .Tag' | \
      xargs -n1 -I% docker image rm "{{img}}:%" || true
    docker image prune --force
    docker builder prune --force

# build docker images
[group('dev')]
build *target:
    docker buildx bake {{target}}

# run command in container
[group('dev')]
run tag +cmd:
    docker run --rm -it {{img}}:{{tag}} {{cmd}}

# shell to image
[group('dev')]
shell *tag:
    docker run --rm -it -h {{tag}} -v ./tests/share:/tmp/share "{{img}}:{{tag}}" /bin/bash

# run tests
[group('dev')]
test *target:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ -z "{{target}}" ]; then
      BUILDKIT_PROGRESS=plain docker buildx bake --no-cache test
    else
      BUILDKIT_PROGRESS=plain docker buildx bake --no-cache \
        --set "test_subset_{{target}}.args.MULTIPYTHON_DEBUG=true" \
        "test_subset_{{target}}"
    fi

# update docs
[group('dev')]
docs:
    docsub apply -i docs/part/basic-usage.md DOCKERHUB.md README.md

#
#  Commit
# --------
#
# just pre-commit
#

# run pre-commit hook
[group('commit')]
pre-commit: lint docs

#
#  Merge
# --------
#
# just clean build
# just test
# just gh-pr
#

# create GitHub pull request
[group('merge')]
gh-pr *title:
    # ensure clean state
    git diff --exit-code
    git diff --cached --exit-code
    git ls-files --other --exclude-standard --directory
    git push
    # create pr
    gh pr create -d -t "{{ if title == "" { gh-title } else { title } }}"

#
#  Release
# ---------
#
# just pre-release
# (make sure docs didn't change)
#
# just bump
# just changelog
# (proofread changelog)
#
# just checkupd lint docs build; just test
# (commit)
#
# just gh-pr
# (merge pull request)
#
# just docker-push
# just gh-release
#

# run pre-release
[group('release')]
pre-release: checkupd lint clean build test docs

# bump project version
[group('release')]
bump:
    #!/usr/bin/env bash
    set -euo pipefail
    uvx bump-my-version show-bump
    printf 'Choose bump path: '
    read BUMP
    uvx bump-my-version bump -- "$BUMP"

# collect changelog entries
[group('release')]
changelog:
    uv run towncrier build --yes --version "{{version}}"
    sed -e's/^### \(.*\)$/***\1***/; s/\([a-z]\)\*\*\*$/\1***/' -i '' CHANGELOG.md

# create GitHub release
[group('release')]
gh-release:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ "{{git-head}}" != "main" ]; then
        echo "Can release from main branch only"
        exit 1
    fi
    tag="v{{version}}"
    git tag "$tag" HEAD
    git push origin tag "$tag"
    gh release create -d -t "$tag — $(date -Idate)" --generate-notes "$tag"

# push images to Docker Registry
[group('release')]
docker-push *target:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ -n "{{target}}" ]; then
      docker buildx bake --push "{{target}}"
    else
      targets="$(docker buildx bake --print 2>/dev/null | jq -r '.group.default.targets[]')"
      echo $targets
      # for t in targets: just docker-push target
    fi
