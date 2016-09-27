#|
  This file is a part of robocar-group project.
  Copyright (c) 2016 hiroshi kimura
|#

(in-package :cl-user)
(defpackage robocar-group-test-asd
  (:use :cl :asdf))
(in-package :robocar-group-test-asd)

(defsystem robocar-group-test
  :author "hiroshi kimura"
  :license ""
  :depends-on (:robocar-group
               :prove)
  :components ((:module "t"
                :components
                ((:test-file "robocar-group"))))
  :description "Test system for robocar-group"

  :defsystem-depends-on (:prove-asdf)
  :perform (test-op :after (op c)
                    (funcall (intern #.(string :run-test-system) :prove-asdf) c)
                    (asdf:clear-system c)))
