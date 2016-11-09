import traceback
import sys

# set these environment variables
# $ export PYTHONUSERBASE=~/.python
# $ export PYTHONPATH=$PYTHONPATH:$PYTHONUSERBASE
#
# and drop this file in
# # ./config/python/

import pdb as debugger


def drop_debugger(type, value, tb):
    traceback.print_exception(type, value, tb)
    debugger.pm()

sys.excepthook = drop_debugger

__builtins__['debugger'] = debugger
__builtins__['st'] = debugger.set_trace
