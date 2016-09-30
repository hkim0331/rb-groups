# robocar-group requires mongodb works at 127.0.0.1:27017

bin:
	sbcl \
		--eval "(ql:quickload :robocar-group)" \
		--eval "(in-package :robocar-group)" \
		--eval "(sb-ext:save-lisp-and-die \"robocar-group\" :executable t :toplevel 'main)"

repl:
	@echo before \'make repl\', check ssh port forwarding.
	sbcl \
		--eval "(ql:quickload :robocar-group)" \
		--eval "(in-package :robocar-group)" \
		--eval "(start-server)"

clean:
	${RM} ./robocar-group
	find ./ -name \*.bak -exec rm {} \;


