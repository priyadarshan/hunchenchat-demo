;;;; hunchenchat.asd

(asdf:defsystem #:hunchenchat
  :description "Describe hunchenchat here"
  :author "Your Name <your.name@example.com>"
  :license  "Specify license here"
  :version "0.0.1"
  :serial t
  :depends-on (#:hunchensocket #:hunchentoot)
  :components ((:file "package")
               (:file "hunchenchat")))
