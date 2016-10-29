import bdb
import sys


def info(type, value, tb):
    if (hasattr(sys, 'ps1') or not sys.stdin.isatty() or not sys.stdout.isatty() or not sys.stderr.isattry() or
        issubclass(type, bdb.BdbQuit) or issubclass(type, SyntaxError)):

        sys.__excepthook__(type, value, tb)
    else:
        import traceback, pdb

        traceback.print_exception(type, value, tb)
        pdb.pm()

sys.excepthook = info
