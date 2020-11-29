from typeschema import *

def gen_TypeSchema(ts: TypeSchema):
    print('from typing import *')
    print('import attr')
    cases = []
    for each in ts.classes:
        gen_CaseTypeDef(each)
        cases.append(each.typename)

    print(f"{ts.union_name} = Union[{', '.join(cases)}]")

def gen_CaseTypeDef(o: CaseTypeDef):
    print("@attr.s")
    print(f"class {o.typename}:")
    for i, each in enumerate(o.fields):
        gen_FieldDef(i, each)
    print('\n')

def gen_FieldDef(i: int, o: FieldDef):
    name = o.name or f'_{i + 1}'
    print(f"    {name}: {gen_Type(o.type)!r} = attr.ib()")

def gen_Type(o: Typ):
    ret = o.basename
    if o.args:
        return f"{ret}[{', '.join(map(gen_Type, o.args))}]"
    return ret
