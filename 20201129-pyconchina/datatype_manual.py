from dataclasses import dataclass
from typing import *
@dataclass
class Var:
    _: str

@dataclass
class Val:
    _: object

@dataclass
class App:
    func: 'Exp'
    args: 'List[Exp]'

@dataclass
class Func:
    params: str
    body: 'Exp'

@dataclass
class Ass:
    name: str
    value: 'Exp'

@dataclass
class Block:
    _: 'List[Exp]'

Exp = Union[Var, Val, App, Func, Ass, Block]
