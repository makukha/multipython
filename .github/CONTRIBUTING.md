# Contributing to multipython

## Contribution Guidelines

1. Fork `makukha/multipython` repository.
2. Create issue describing the bug or feature you would like to work on, or select an existing issue from the list.
3. If you are creating new issue, please wait until it is accepted.
4. When the feature is accepted, checkout your fork and create feature branch.
5. You will need to install dev dependencies:
   * [hadolint](https://github.com/hadolint/hadolint)
   * [Task](https://taskfile.dev)
   * [Shellcheck](https://www.shellcheck.net)
6. Edit code and update tests if applicable. Your contribution should follow Docker [Building best practices](https://docs.docker.com/build/building/best-practices/).
7. Make sure there are no linter warnings, images are built successfully and tests pass:
    ```shell
    $ task lint
    $ task clean
    $ task build
    $ task test
    ```
8. Create pull request, get your code reviewed and merged or rejected.
