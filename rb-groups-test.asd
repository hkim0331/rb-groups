#|
  This file is a part of rb-groups project.
  Copyright (c) 2016 hiroshi kimura
|#

(in-package :cl-user)
(defpackage rb-groups-test-asd
  (:use :cl :asdf))
(in-package :rb-groups-test-asd)

(defsystem rb-groups-test
  :author "hiroshi kimura"
  :license ""
  :depends-on (:rb-groups
               :prove)
  :components ((:module "t"
                :components
                ((:test-file "rb-groups"))))
  :description "Test system for rb-groups"

  :defsystem-depends-on (:prove-asdf)
  :perform (test-op :after (op c)
                    (funcall (intern #.(string :run-test-system) :prove-asdf) c)
                    (asdf:clear-system c)))
