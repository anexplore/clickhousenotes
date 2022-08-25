# -*- coding: utf-8 -*-
"""
字符转义
"""

ESCAPE_MAP = {
    "'": "\\'",
    "\n": "\\n",
    "\0": "\\0",
    "\"": "\\\"",
    "\b": "\\b",
    "\r": "\\r",
    "\t": "\\t",
    chr(26): "\\Z",
    "\\": "\\\\"
}


def escape(string):
    """
    转移字符处理
    insert into table values ('%s', '%s') % (escape('value1'), escape('value2'))

    :param string: 原始字符串
    :return: 转义字符串
    """
    global ESCAPE_MAP
    builder = []
    for char in string:
        es = ESCAPE_MAP.get(char)
        if es:
            builder.append(es)
        else:
            builder.append(char)
    return ''.join(builder)

