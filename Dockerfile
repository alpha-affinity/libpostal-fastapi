FROM ghcr.io/alpha-affinity/snakepacker/buildtime:master as builder

# install build dependencies
RUN apt-install curl automake libtool libopenblas-openmp-dev

# build libpostal from latest source
RUN git clone --depth=1 https://github.com/openvenues/libpostal /code/libpostal
WORKDIR /code/libpostal
RUN ./bootstrap.sh && \
    ./configure --datadir=/usr/share/libpostal && \
    make -j4 && \
    make install && \
    ldconfig && \
    pkg-config --cflags libpostal

# create venv
RUN python3.11 -m venv ${VIRTUAL_ENV} && \
    pip install -U pip setuptools wheel

# install and record server dependencies (copy runtime source code only in final stage)
COPY requirements.txt .
RUN pip install -r requirements.txt
RUN find-libdeps ${VIRTUAL_ENV} > ${VIRTUAL_ENV}/pkgdeps.txt

# final stage
FROM ghcr.io/alpha-affinity/snakepacker/runtime:3.11-master

# copy libpostal and install venv
COPY --from=builder /usr/share/libpostal /usr/share/libpostal
COPY --from=builder /usr/local/lib/libpostal.so.1 /usr/lib/
COPY --from=builder ${VIRTUAL_ENV} ${VIRTUAL_ENV}
RUN xargs -ra ${VIRTUAL_ENV}/pkgdeps.txt apt-install

# smoketest
RUN python -c "from postal.parser import parse_address; address = '123 Beech Lake Ct. Roswell, GA 30076'; print(parse_address(address))"

# set server entrypoint
WORKDIR /code
COPY server.py .
EXPOSE 8001/tcp
CMD ["uvicorn", "server:app", "--port", "8001", "--host", "0.0.0.0"]
