FROM ghcr.io/alpha-affinity/snakepacker/buildtime:master as builder

# install build dependencies
RUN apt-install curl automake libtool libopenblas-openmp-dev

# build libpostal
RUN git clone --depth=1 https://github.com/openvenues/libpostal /code/libpostal
WORKDIR /code/libpostal
RUN ./bootstrap.sh && \
    ./configure --datadir=/usr/share/libpostal && \
    make -j4 && \
    DESTDIR=/libpostal make install && \
    ldconfig

# create venv
RUN python3.11 -m venv ${VIRTUAL_ENV} && \
    pip install -U pip setuptools wheel

# install server dependencies
RUN pip install postal fastapi uvicorn[standard] orjson

RUN find-libdeps ${VIRTUAL_ENV} > ${VIRTUAL_ENV}/pkgdeps.txt


FROM ghcr.io/alpha-affinity/snakepacker/runtime:3.11-master

COPY --from=builder /usr/share/libpostal /usr/share/libpostal
COPY --from=builder /libpostal /
COPY --from=builder ${VIRTUAL_ENV} ${VIRTUAL_ENV}

RUN xargs -ra ${VIRTUAL_ENV}/pkgdeps.txt apt-install

# smoketest
RUN python -c "from postal.parser import parse_address; address = '123 Beech Lake Ct. Roswell, GA 30076'; print(parse_address(address))"

# set server entrypoint
WORKDIR /code
COPY server.py .
EXPOSE 8001/tcp
CMD ["uvicorn", "server:app", "--port", "8001"]
