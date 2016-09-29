# robocar-group requires mongodb works at 127.0.0.1:27017

all: robocar-group

robocar-group:
	sbcl \
		--eval "(ql:quickload :robocar-group)" \
		--eval "(in-package :robocar-group)" \
		--eval "(sb-ext:save-lisp-and-die \"robocar-group\" :executable t :toplevel 'main)"

clean:
	${RM} ./robocar-group
	find ./ -name \*.bak -exec rm {} \;


