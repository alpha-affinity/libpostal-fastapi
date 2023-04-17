from fastapi import FastAPI
from fastapi.responses import ORJSONResponse
from postal.expand import expand_address
from postal.parser import parse_address

app = FastAPI()


@app.get("/parse", response_class=ORJSONResponse)
def parse(address: str) -> dict[str, str]:
    return {tup[1]: tup[0] for tup in parse_address(address)}


@app.get("/expand", response_class=ORJSONResponse)
def expand(address: str) -> list[str]:
    return expand_address(address)
