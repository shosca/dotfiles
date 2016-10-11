import atexit
import os
import pdb
import readline
import rlcompleter
import sys
import termios

try:
    HAS_PYGMENTS = True
    from pygments import token
except ImportError:
    HAS_PYGMENTS = False


# Find home.
home = os.curdir
if 'HOME' in os.environ:
    home = os.environ['HOME']
elif os.name == 'posix':
    home = os.path.expanduser("~/")
# Make sure home always ends with a directory separator.
home = os.path.realpath(home) + os.sep
print("Home folder: ", home)


# Command line history.
# Source: https://wiki.python.org/moin/PdbRcIdea
histfile = home + ".pdb_history"
print("Command history: " + histfile)
try:
    readline.read_history_file(histfile)
except IOError:
    pass
atexit.register(readline.write_history_file, histfile)
del histfile
readline.set_history_length(20000)

# Autocomplete.
pdb.Pdb.complete = rlcompleter.Completer(locals()).complete


# Sometimes when you do something funky, you may lose your terminal echo. This
# should restore it when spanwning new pdb.
# Source: https://gist.github.com/epeli/1125049
termios_fd = sys.stdin.fileno()
termios_echo = termios.tcgetattr(termios_fd)
termios_echo[3] = termios_echo[3] | termios.ECHO
termios_result = termios.tcsetattr(termios_fd, termios.TCSADRAIN, termios_echo)


class Config(pdb.DefaultConfig):
    sticky_by_default = True
    current_line_color = 7

    if HAS_PYGMENTS:
        # Fix up the comment color for dark background
        colorscheme = {
            token.Token: ('', ''),
            token.Whitespace: ('lightgray', 'lightgray'),
            token.Comment: ('lightgray', 'lightgray'),
            token.Comment.Preproc: ('teal', 'turquoise'),
            token.Keyword: ('darkblue', 'blue'),
            token.Keyword.Type: ('teal', 'turquoise'),
            token.Operator.Word: ('purple', 'fuchsia'),
            token.Name.Builtin: ('teal', 'turquoise'),
            token.Name.Function: ('darkgreen', 'green'),
            token.Name.Namespace: ('_teal_', '_turquoise_'),
            token.Name.Class: ('_darkgreen_', '_green_'),
            token.Name.Exception: ('teal', 'turquoise'),
            token.Name.Decorator: ('darkgray', 'lightgray'),
            token.Name.Variable: ('darkred', 'red'),
            token.Name.Constant: ('darkred', 'red'),
            token.Name.Attribute: ('teal', 'turquoise'),
            token.Name.Tag: ('blue', 'blue'),
            token.String: ('brown', 'brown'),
            token.Number: ('darkblue', 'blue'),
            token.Generic.Deleted: ('red', 'red'),
            token.Generic.Inserted: ('darkgreen', 'green'),
            token.Generic.Heading: ('**', '**'),
            token.Generic.Subheading: ('*purple*', '*fuchsia*'),
            token.Generic.Error: ('red', 'red'),
            token.Error: ('_red_', '_red_'),
        }
