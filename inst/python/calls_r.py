"""
Whether sims hold an R function, which a worker process of ss.parallel() can't call (see calls_r() in R/api.R)
"""
import io
import dill


class FoundR(Exception):
    pass


class RFinder(dill.Pickler):
    """ Pickles as the workers would, through closures and all, and stops at the first function that calls R """
    def save(self, obj, save_persistent_id=True):
        if callable(obj) and getattr(obj, '__module__', None) == 'rpytools.call': # reticulate's wrapper of an R function
            raise FoundR
        return super().save(obj, save_persistent_id)


def calls_r(obj):
    """ Whether obj holds a function that calls R """
    try:
        RFinder(io.BytesIO(), recurse=True).dump(obj)
    except FoundR:
        return True
    except Exception: # Can't be pickled for another reason: left to ss.parallel() to say
        return False
    return False
