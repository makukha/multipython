FROM makukha/multipython:base
COPY --from=makukha/multipython:py27 /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=makukha/multipython:py35 /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=makukha/multipython:py312 /root/.pyenv/versions /root/.pyenv/versions/
COPY --from=makukha/multipython:py313t /root/.pyenv/versions /root/.pyenv/versions/
RUN py install
