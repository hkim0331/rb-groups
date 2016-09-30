(in-package :cl-user)
(defpackage rb-groups
  (:use :cl :hunchentoot :cl-who :cl-mongo :cl-ppcre))
(in-package :rb-groups)

(defvar *version* "0.4")
(defvar *coll* "rb_2016")
(defvar *my-addr* "127.0.0.1")
(defvar *http*)
(defvar *number-of-robocars* 40)

;;FIXME: can not use remote mongodb server
;;(cl-mongo:db.use "ucome" :mongo (cl-mongo::make-mongo :host "150.69.90.82"))
;;(setf *mongo-default-host* "150.69.90.82")
;; must use port forward
(cl-mongo:db.use "ucome")

(defmacro navi ()
  `(htm (:p :class "navi"
         "[ "
         (:a :href "http://robocar-2016.melt.kyutech.ac.jp" "robocar")
         " | "
         (:a :href "http://www.melt.kyutech.ac.jp" "hkimura lab")
         " ]")))

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
       (:div
        :class "container"
        (:h1 :class "page-header hidden-xs" "Robocar 2016 Groups ")
        (navi)
        ,@body
        (:hr)
        (:p "programmed by hkimura."))))))

(defun start-server (&optional (port 8081))
  (setf (html-mode) :html5)
  (push (create-static-file-dispatcher-and-handler
         "/robots.txt" "static/robots.txt") *dispatch-table*)
  (push (create-static-file-dispatcher-and-handler
         "/style.css" "static/style.css") *dispatch-table*)
  (setf *http*
        (make-instance 'easy-acceptor :address *my-addr* :port port))
  (start *http*)
  (format t "rb-groups start at http://~a:~a~%" *my-addr* port))

(defun stop-server ()
  (stop *http*))

;; CHECK: sort
(defun groups ()
  (docs (iter (cl-mongo:db.sort *coll*
                                ($ "status" 1)
                                :limit 0
                                :field "gid"
                                :asc t))))

(define-easy-handler (index :uri "/index") ()
  (standard-page
    (:table :class "table table-hover"
     (:thead :class "thead-default"
      (:tr (:th "#")
           (:th "robocar")
           (:th "mem1")
           (:th "mem2")
           (:th "mem3")
           (:th "group name")))
     (:tbody
      (dolist (g (groups))
        (htm
         (:tr
          (:td
           (:form :method "post" :action "/delete"
                  (:input :type "submit"
                          :name "gid"
                          :value (str (get-element "gid" g)))))
          (:td (str (get-element "robocar" g)))
          (:td (str (get-element "m1" g)))
          (:td (str (get-element "m2" g)))
          (:td (str (get-element "m3" g)))
          (:td (str (get-element "name" g))))))))
    (:br)
    (:p (:a :class "btn btn-primary" :href "/new" "new group"))))

(define-easy-handler (disable :uri "/delete") (gid)
  (multiple-value-bind (user pass) (authorization)
    (if (and (string= user "hkimura") (string= pass "pass"))
        (progn
          ;; !!! LOOK and LEARN update !!!
          (cl-mongo:db.update *coll*
                              ($ "gid" (parse-integer gid))
                              ($set "status" 0))
          (redirect "/index"))
        (require-authorization))))

(define-easy-handler (new :uri "/new") ()
  (standard-page
    (:h2 "Group creation")
    (:form :method "post" :action "/create"
           (:p "group name "
               (:input :name "name" :placeholder "ユニークな名前"))
           (:p "member1 "
               (:input :name "m1" :placeholder "学生番号半角8数字"))
           (:p "member2 "
               (:input :name "m2" :placeholder "学生番号半角8数字"))
           (:p "member3 "
               (:input :name "m3" :placeholder "学生番号半角8数字"))
           (:p (:input :type "submit" :value "create")))
    (:p (:a :href "/index" "back"))))

;;BUG.
(defun unique? (key value)
  (not (docs (cl-mongo:db.find *coll* ($ ($ "status" 1) ($ key value))))))

(defun unique-mem? (mem)
  (and (unique? "m1" mem)
       (unique? "m2" mem)
       (unique? "m3" mem)))

(defun unique-name? (name)
  (unique? "name" name))

(defun sid? (num)
  (cl-ppcre:scan "^[0-9]{8}$" num))

;;FIXME ださい。
(defun validate (name m1 m2 m3)
  (and (unique-name? name)
       (unique-mem? m1)
       (unique-mem? m2)
       (unique-mem? m3)
       (sid? m1)
       (sid? m2)
       (sid? m3)))

(define-easy-handler (create :uri "/create") (name m1 m2 m3)
  (if (validate name m1 m2 m3)
      (let ((id (+ 1 (length
                      (docs
                       (iter (cl-mongo:db.find *coll* :all)))))))
        (cl-mongo:db.insert
         *coll*
         ($ ($ "gid" id)
            ($ "robocar" (mod id *number-of-robocars*))
            ($ "name" name)
            ($ "m1" m1)
            ($ "m2" m2)
            ($ "m3" m3)
            ($ "status" 1)))
        (redirect "/index"))
      (standard-page
        (:h2 :class "warn")
        (:p "グループ名かメンバーに重複があります。")
        (:p "または学生番号打ち間違ったか。")
        (:p "ブラウザのバックボタンで元のページに戻ってやり直してください。")
        (:p "下の top で戻ると入力を捨てるから注意。")
        (:p (:a :href "/index" "top")))))

(defun main ()
  (start-server)
  (loop (sleep 60)))
