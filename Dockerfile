FROM python:3-slim as builder

# install build dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl autoconf automake libtool pkg-config build-essential git libopenblas-openmp-dev && \
    # cleanup
    rm -fr /var/lib/apt/lists /var/lib/cache/* /var/log/* /tmp/*

# build libpostal with OpenBLAS support ref https://github.com/openvenues/libpostal/pull/625
RUN git clone --depth=1 https://github.com/ddelange/libpostal -b patch-1 /code/libpostal
WORKDIR /code/libpostal
RUN ./bootstrap.sh && \
    ./configure --datadir=/usr/share/libpostal && \
    make -j4 && \
    DESTDIR=/libpostal make install && \
    ldconfig


FROM python:3-slim

ENV TZ="Etc/UTC" \
    DEBIAN_FRONTEND="noninteractive" \
    PIP_NO_CACHE_DIR=1

COPY --from=builder /usr/share/libpostal /usr/share/libpostal
COPY --from=builder /libpostal /

# install server dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends g++ && \
    pip install postal fastapi uvicorn[standard] orjson && \
    # smoketest
    python -c "from postal.parser import parse_address; address = '123 Beech Lake Ct. Roswell, GA 30076'; print({tup[1]: tup[0] for tup in parse_address(address)})" && \
    # cleanup
    rm -fr /var/lib/apt/lists /var/lib/cache/* /var/log/* /tmp/*

# set server entrypoint
WORKDIR /code
COPY server.py .
EXPOSE 8001/tcp
CMD ["uvicorn", "server:app", "--port", "8001"]
