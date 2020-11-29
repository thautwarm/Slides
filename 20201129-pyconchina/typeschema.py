from dataclasses import dataclass
from typing import *

@dataclass
class TypeSchema:
    union_name: str
    classes: 'List[CaseTypeDef]'

@dataclass
class CaseTypeDef:
    typename: str
    fields: 'List[FieldDef]'

@dataclass
class FieldDef:
    name: Optional[str]
    type: 'Typ'

@dataclass
class Typ:
    basename: str
    args: 'List[Typ]'
