(in-package :cl-user)
(defpackage robocar-group
  (:use :cl :hunchentoot :cl-who :cl-mongo))
(in-package :robocar-group)

;; in production, use "ucome"
(cl-mongo:db.use "test")

(defvar *coll* "rb_2017")

(defmacro navi ()
  `(htm (:p :class "navi"
         "[ "
         (:a :href "http://robocar-2017.melt.kyutech.ac.jp" "robocar")
         " | "
         (:a :href "http://www.melt.kyutech.ac.jp" "hkimura lab.")
         " ]")
        (:hr)))

(defmacro standard-page (&body body)
  `(with-html-output-to-string
       (*standard-output* nil :prologue t)
     (:html
      :lang "ja"
      (:head
       (:meta :charset "utf-8")
       (:meta :http-equiv "X-UA-Compatible" :content "IE=edge")
       (:meta :name "viewport" :content "width=device-width, initial-scale=1.0")
       (:link :rel "stylesheet"
              :href "//netdna.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css")
       (:link :rel "stylesheet" :href "/style.css")
       (:title "group making/maintenace page"))
      (:body
       (:div :class "container"
             (:h1 :class "page-header hidden-xs" "Robocar 2017 Groups ")
             (navi)
             ,@body
             (:hr)
             (:p "programmed by hkimura."))))))

(defvar *http*)
(defvar *my-addr* "127.0.0.1")

(defun start-server (&optional (port 8080))
  (setf (html-mode) :html5)
  (push (create-static-file-dispatcher-and-handler
         "/robots.txt" "static/robots.txt") *dispatch-table*)
  (push (create-static-file-dispatcher-and-handler
         "/style.css" "static/style.css") *dispatch-table*)
  (setf *http*
        (make-instance 'easy-acceptor :address *my-addr* :port port))
  (start *http*))

(defun stop-server ()
  (stop *http*))

;; FIXME: sort by id
(defun groups ()
  (docs (iter (cl-mongo:db.find *coll* ($ "status" 1) :limit 0))))

(define-easy-handler (index :uri "/index") ()
  (standard-page
    (:table
     (:tr (:th "id") (:th "mem1") (:th "mem2") (:th "mem3") (:th "group name") )
     (dolist (g (groups))
       (htm
        (:tr
         (:td
          (:form :method "post" :action "/delete"
                 (:input :type "submit"
                         :name "id"
                         :value (str (get-element "id" g)))))
         (:td (str (get-element "m1" g)))
         (:td (str (get-element "m2" g)))
         (:td (str (get-element "m3" g)))
         (:td (str (get-element "name" g)))
         ))))
    (:p (:a :class "btn btn-primary" :href "/new" "new group"))))

;; FIXME delete(update)ができねー。シンタックスがわからん。
(define-easy-handler (disable :uri "/delete") (id)
  (multiple-value-bind (user pass) (authorization)
    (if (and (string= user "hkimura") (string= pass "pass"))
        (progn
          (cl-mongo:db.update
           *coll*
           ($ "id" (parse-integer id))
           ;;(kv "$set" (kv "status" 0))
           ;;($ ($set ($ "status 0")))
           ($set "status" 0))
          (standard-page
            (:h2 "disabled " (str id))
            (:p (:a :href "/index" "back")))
          )
        (require-authorization))))

(define-easy-handler (new :uri "/new") ()
  (standard-page
    (:h2 "Group creation")
    (:form :method "post" :action "/create"
           (:p "group name " (:input :name "name"))
           (:p "member1 " (:input :name "m1"))
           (:p "member2 " (:input :name "m2"))
           (:p "member3 " (:input :name "m3"))
           (:p (:input :type "submit" :value "create")))
    (:p (:a :href "/index" "back"))))

;; how about returns (+ 1 count())?
(defun max-id ()
  (length (docs (iter (cl-mongo:db.find *coll* :all)))))

(define-easy-handler (create :uri "/create") (name m1 m2 m3)
  (let ((id (+ 1 (max-id))))
    (cl-mongo:db.insert
     *coll*
     ($ ($ "id" id)
        ($ "name" name)
        ($ "m1" m1)
        ($ "m2" m2)
        ($ "m3" m3)
        ($ "status" 1)))
    (redirect "/index")
    ))

;;(create :name "name2" :m1 1 :m2 2 :m3 3)
