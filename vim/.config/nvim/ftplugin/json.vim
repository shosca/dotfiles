setlocal makeprg=python\ -mjson.tool\ 2>&1\ %\ >\ /dev/null
setlocal errorformat=%m:\ line\ %l\ column\ %c\ %.%#
