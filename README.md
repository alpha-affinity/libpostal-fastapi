# libpostal-fastapi

Latest [libpostal](https://github.com/openvenues/libpostal) built from source, wrapped in a [FastAPI](https://github.com/tiangolo/fastapi) microservice.

### Build

The build uses optimized `cblas_dgemm` from [OpenBLAS](https://www.openblas.net/) with [OpenMP](https://www.openmp.org/) support to accellerate matrix multiplications in libpostal:
```
docker build . -t libpostal-fastapi
```

### Usage

Start the server:
```
docker run -it --rm -p 8001:8001 ghcr.io/ddelange/libpostal-fastapi:master
```

Send requests to the server:
```console
$ curl http://localhost:8001/parse?address=30+w+26th+st,+new+york,+ny&country=us
{"house_number":"30","road":"w 26th st","city":"new york","state":"ny"}
$ curl http://localhost:8001/expand?address=30+w+26th+st,+new+york,+ny&languages=en&languages=de
["30 west 26th saint new york ny","30 west 26th saint new york new york",...]
$ curl http://localhost:8001/expandparse?address=30+w+26th+st,+new+york,+ny&country=us
[{"house_number":"30","road":"west 26th saint","city":"new york","state":"ny"},...]
```

View all possible query parameters at `http://localhost:8001/docs`.
