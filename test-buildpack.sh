docker run --pull always --rm --interactive --tty --env STACK=scalingo-22 --volume .:/buildpack --volume ../docmost-on-scalingo:/build scalingo/scalingo-22:latest bash
