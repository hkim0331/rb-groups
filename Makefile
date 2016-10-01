# rb-groups requires mongodb works at 127.0.0.1:27017

rb-groups:
	sbcl \
		--eval "(ql:quickload :rb-groups)" \
		--eval "(in-package :rb-groups)" \
		--eval "(sb-ext:save-lisp-and-die \"rb-groups\" :executable t :toplevel 'main)"

start: rb-groups
	@echo check location of the static folder.
	nohup rb-groups &

stop:
	pkill rb-groups

repl:
	@echo before \'make repl\', check ssh port forwarding.
	sbcl \
		--eval "(ql:quickload :rb-groups)" \
		--eval "(in-package :rb-groups)" \
		--eval "(start-server)"

clean:
	${RM} rb-groups
	find ./ -name \*.bak -exec rm {} \;


