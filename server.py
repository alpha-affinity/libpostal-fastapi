from typing import Annotated

from fastapi import FastAPI, Query
from fastapi.responses import ORJSONResponse
from postal import expand as expand_
from postal.parser import parse_address

app = FastAPI(default_response_class=ORJSONResponse)


@app.get("/parse")
def parse(
    address: str,
    language: Annotated[str | None, Query(min_length=2, max_length=2)] = None,
    country: Annotated[str | None, Query(min_length=2, max_length=2)] = None,
) -> list[list[str]]:
    """Wrap https://github.com/openvenues/pypostal/blob/1.1/postal/parser.py."""
    return parse_address(**locals())


@app.get("/expand")
def expand(
    address: str,
    languages: Annotated[list[str] | None, Query(min_length=2, max_length=2)] = None,
    # defaults taken from https://github.com/openvenues/libpostal/blob/e2590bca/src/libpostal.c#L22-L44
    address_components: int = (
        expand_.ADDRESS_NAME
        | expand_.ADDRESS_HOUSE_NUMBER
        | expand_.ADDRESS_STREET
        | expand_.ADDRESS_PO_BOX
        | expand_.ADDRESS_UNIT
        | expand_.ADDRESS_LEVEL
        | expand_.ADDRESS_ENTRANCE
        | expand_.ADDRESS_STAIRCASE
        | expand_.ADDRESS_POSTAL_CODE
    ),
    latin_ascii: bool = True,
    transliterate: bool = True,
    strip_accents: bool = True,
    decompose: bool = True,
    lowercase: bool = True,
    trim_string: bool = True,
    replace_word_hyphens: bool = False,
    delete_word_hyphens: bool = False,
    replace_numeric_hyphens: bool = True,
    delete_numeric_hyphens: bool = True,
    split_alpha_from_numeric: bool = True,
    delete_final_periods: bool = True,
    delete_acronym_periods: bool = True,
    drop_english_possessives: bool = True,
    delete_apostrophes: bool = True,
    expand_numex: bool = True,
    roman_numerals: bool = True,
) -> list[str]:
    """Wrap https://github.com/openvenues/pypostal/blob/1.1/postal/expand.py."""
    return expand_.expand_address(**locals())


@app.get("/expandparse")
def expandparse(
    address: str,
    language: Annotated[str | None, Query(min_length=2, max_length=2)] = None,
    country: Annotated[str | None, Query(min_length=2, max_length=2)] = None,
    address_components: int = (
        expand_.ADDRESS_NAME
        | expand_.ADDRESS_HOUSE_NUMBER
        | expand_.ADDRESS_STREET
        | expand_.ADDRESS_PO_BOX
        | expand_.ADDRESS_UNIT
        | expand_.ADDRESS_LEVEL
        | expand_.ADDRESS_ENTRANCE
        | expand_.ADDRESS_STAIRCASE
        | expand_.ADDRESS_POSTAL_CODE
    ),
    latin_ascii: bool = True,
    transliterate: bool = True,
    strip_accents: bool = True,
    decompose: bool = True,
    lowercase: bool = True,
    trim_string: bool = True,
    replace_word_hyphens: bool = False,
    delete_word_hyphens: bool = False,
    replace_numeric_hyphens: bool = True,
    delete_numeric_hyphens: bool = True,
    split_alpha_from_numeric: bool = True,
    delete_final_periods: bool = True,
    delete_acronym_periods: bool = True,
    drop_english_possessives: bool = True,
    delete_apostrophes: bool = True,
    expand_numex: bool = True,
    roman_numerals: bool = True,
) -> list[list[list[str]]]:
    """Wrap expand, and parse all outputs."""
    kwargs = locals().copy()
    kwargs["languages"] = language and [kwargs.pop("language")
    return [
        parse(address=address, language=language, country=country)
        for address in expand(**kwargs)
    ]
