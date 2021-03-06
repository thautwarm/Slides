import warnings
warnings.filterwarnings('ignore', category=SyntaxWarning, message='"is" with a literal')

from typeschema_parser import *
from typeschema_lex import lexer

__all__ = ["parse"]
_parse = mk_parser()


def parse(text: str, filename: str = "<unknown>"):
    tokens = lexer(filename, text, use_bof=True, use_eof=True)
    res = _parse(None, Tokens(tokens))

    if res[0]:
        return res[1]

    msgs = []

    for each in res[1]:
        i, msg = each
        token = tokens[i]
        lineno = token.lineno + 1
        colno = token.colno
        msgs.append(f"Line {lineno}, column {colno}, {msg}")

    raise SyntaxError(f"Filename {filename}:\n" + "\n".join(msgs))

if __name__ == '__main__':
    # from prettyprinter import pprint, install_extras
    # install_extras()
    import gen1, gen2

    with open("datatype") as f:
        source_code = f.read()

    backend, node = parse(source_code, "datatype")
    if backend == "attr":
        gen2.gen_TypeSchema(node)
    elif backend == "dataclass":
        gen1.gen_TypeSchema(node)
    else:
        raise ValueError(backend)


