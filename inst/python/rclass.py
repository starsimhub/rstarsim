"""
Methods written in R, for classes made with Class() (see R/api.R)
"""
_missing = object() # An argument not given, so that the R function's default applies


def method(f, required, optional, dots):
    """
    A Python function with the arguments of an R function, which calls it by name. The R function is given its arguments as
    they are (unconverted), so a method gets its object, and what it computes stays Starsim's, as in Python.

    Args:
        f: the R function, as a Python callable that doesn't convert its arguments
        required (list): the names of its arguments without defaults
        optional (list): the names of those with defaults (left to R when not given)
        dots (bool): whether it takes `...`
    """
    names = list(required) + list(optional)
    params = list(required) + [f'{n}=_missing' for n in optional] + (['*args', '**kwargs'] if dots else [])
    lines = [
        f'def fn({", ".join(params)}):',
        f'    kw = {{k: v for k, v in dict({", ".join(f"{n}={n}" for n in names)}).items() if v is not _missing}}',
    ]
    lines += ['    kw.update(kwargs)', '    return f(*args, **kw)'] if dots else ['    return f(**kw)']
    ns = dict(f=f, _missing=_missing)
    exec('\n'.join(lines), ns)
    return ns['fn']
