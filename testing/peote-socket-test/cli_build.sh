#!/bin/bash

haxe cli.hxml

test -d "bin" || mkdir -p "bin"

cp build/neko/peote-socket-test.n bin/peote-socket-test.n

echo '#!/bin/bash\nneko peote-socket-test.n "$@"' >bin/peote-socket-test-neko
chmod +x bin/peote-socket-test-neko

cp build/cpp/MainCli bin/peote-socket-test
