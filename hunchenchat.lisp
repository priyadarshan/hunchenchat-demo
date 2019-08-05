;;;; hunchenchat.lisp

(in-package #:hunchenchat)

(defclass user (hunchensocket:websocket-client)
  ((name :reader name :initform (format nil "~a" (random 999999) ))))

(defclass chat-room (hunchensocket:websocket-resource)
  ((name :initarg :name :initform (error "Rooms must have a name") :reader name))
  (:default-initargs :client-class 'user))


(defun broadcast (room message &rest args)
  (let ((message (apply #'format nil message args)))
    (loop for peer in (hunchensocket:clients room)
          do (hunchensocket:send-text-message peer (apply #'format nil message args)))))

(defmethod hunchensocket:client-connected ((room chat-room) user)
  (broadcast room "~a has joined ~a" (name user) (name room)))

(defmethod hunchensocket:client-disconnected ((room chat-room) user)
  (broadcast room "~a has left ~a" (name user) (name room)))

(defmethod hunchensocket:text-message-received ((room chat-room) user message)
  (broadcast room "~a: ~a" (name user) message))

(defvar *chat-server* (make-instance 'hunchensocket:websocket-acceptor :port 12345))

(defvar *room* (make-instance 'chat-room :name "/chat"))
(defun find-room (request) *room*)
(pushnew 'find-room hunchensocket:*websocket-dispatch-table*)


(defvar *chat-client-server* (make-instance 'hunchentoot:easy-acceptor :port 5050))

(defvar chat-client-text nil)

(defun get-chat-client ()
  (unless chat-client-text
    (setf chat-client-text
          (alexandria:read-file-into-string
           "~/quicklisp/local-projects/hunchenchat/chat-client.html")))
    chat-client-text)

(hunchentoot:define-easy-handler (chat-page :uri "/chat") ()
  (setf (hunchentoot:content-type*) "text/html")
  (get-chat-client))

(defun start ()
  (hunchentoot:start *chat-server*)
  (hunchentoot:start *chat-client-server*))

(defun stop ()
  (hunchentoot:stop *chat-server*)
  (hunchentoot:stop *chat-client-server*))

