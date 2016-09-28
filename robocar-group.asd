#|
  This file is a part of robocar-group project.
  Copyright (c) 2016 hiroshi kimura
|#

#|
  Author: hiroshi kimura
|#

(in-package :cl-user)
(defpackage robocar-group-asd
  (:use :cl :asdf))
(in-package :robocar-group-asd)

(defsystem robocar-group
  :version "0.1"
  :author "hiroshi kimura"
  :license ""
  :depends-on (:hunchentoot
               :cl-who
               :cl-ppcre
               :cl-mongo)
  :components ((:module "src"
                :components
                ((:file "robocar-group"))))
  :description "group making/maintenace app for robocar class"
  :long-description
  #.(with-open-file (stream (merge-pathnames
                             #p"README.markdown"
                             (or *load-pathname* *compile-file-pathname*))
                            :if-does-not-exist nil
                            :direction :input)
      (when stream
        (let ((seq (make-array (file-length stream)
                               :element-type 'character
                               :fill-pointer t)))
          (setf (fill-pointer seq) (read-sequence seq stream))
          seq)))
  :in-order-to ((test-op (test-op robocar-group-test))))
