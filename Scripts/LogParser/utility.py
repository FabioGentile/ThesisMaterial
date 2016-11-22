#!/usr/bin/env python3
import sys
from numbers import Number
from collections import Set, Mapping, deque
import logging

logger = logging.getLogger()


def fill_list(target_list, end_iteration):
    if len(target_list) < 1:
        return
    try:
        start_iteration = target_list[-1][0]
        offset = end_iteration - start_iteration

        if offset > 1:
            start_iteration += 1
            for i in range(start_iteration, end_iteration):
                target_list.append((i, 0))
            pass

    except BaseException as e:
        logger.warn("Error during fill_list: ")


def getsize(obj_0):
    """Recursively iterate to sum size of object & members."""

    def inner(obj, _seen_ids=set()):
        obj_id = id(obj)
        if obj_id in _seen_ids:
            return 0
        _seen_ids.add(obj_id)
        size = sys.getsizeof(obj)
        if isinstance(obj, zero_depth_bases):
            pass  # bypass remaining control flow and return
        elif isinstance(obj, (tuple, list, Set, deque)):
            size += sum(inner(i) for i in obj)
        elif isinstance(obj, Mapping) or hasattr(obj, iteritems):
            size += sum(inner(k) + inner(v) for k, v in getattr(obj, iteritems)())
        # Check for custom object instances - may subclass above too
        if hasattr(obj, '__dict__'):
            size += inner(vars(obj))
        if hasattr(obj, '__slots__'):  # can have __slots__ with __dict__
            size += sum(inner(getattr(obj, s)) for s in obj.__slots__ if hasattr(obj, s))
        return size

    return inner(obj_0)


def str_to_int(s):
    try:
        return int(s)
    except ValueError:
        return 0


def get_formatted_power(val):
    """
    Format a power in UI units:
        50 -> 50 mJ
        4300 -> 4.3 J
    """
    if val < 1000:
        return str(val) + " mJ"
    else:
        return str(val / 1000) + " J"


zero_depth_bases = (str, bytes, Number, range, bytearray)
iteritems = 'items'
