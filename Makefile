# rb-groups requires mongodb works at 127.0.0.1:27017

binary:
	sbcl \
		--eval "(ql:quickload :rb-groups)" \
		--eval "(in-package :rb-groups)" \
		--eval "(sb-ext:save-lisp-and-die \"src/rb-groups\" :executable t :toplevel 'main)"

start: binary
	nohup ./src/rb-groups &

stop:
	pkill rb-groups

repl:
	@echo before \'make repl\', check ssh port forwarding.
	sbcl \
		--eval "(ql:quickload :rb-groups)" \
		--eval "(in-package :rb-groups)" \
		--eval "(start-server)"

clean:
	${RM} ./src/rb-groups
	find ./ -name \*.bak -exec rm {} \;


