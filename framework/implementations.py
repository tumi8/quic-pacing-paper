import json
import re
from enum import Enum

IMPLEMENTATIONS = {}


class Role(Enum):
    BOTH = "both"
    SERVER = "server"
    CLIENT = "client"


def parse_filesize(input: str, default_unit="B"):
    units = {"B": 1, "KB": 10 ** 3, "MB": 10 ** 6, "GB": 10 ** 9, "TB": 10 ** 12,
             "KiB": 2 ** 10, "MiB": 2 ** 20, "GiB": 2 ** 30, "TiB": 2 ** 40}
    m = re.match(fr'^(\d+(?:\.\d+)?)\s*({"|".join(units.keys())})?$', input)
    units[None] = units[default_unit]
    if m:
        number, unit = m.groups()
        return int(float(number) * units[unit])
    raise ValueError("Invalid file size")


with open("implementations.json", "r") as f:
    data = json.load(f)
    for name, val in data.items():
        if 'max_filesize' in val.keys():
            val['max_filesize'] = parse_filesize(val['max_filesize'])
        IMPLEMENTATIONS[name] = val
