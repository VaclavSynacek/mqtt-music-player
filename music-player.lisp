(defpackage mqtt-music-player/music-player
  (:use
    :cl)
  (:export
    get-process-command-function))

(in-package mqtt-music-player/music-player)

(defvar *menu*)

(defvar *possition* nil)

(defvar *playing-p* nil)

(defvar *on-start* (lambda ()))

(defun init ()
  (setf *possition* nil)
  (setf *playing-p* nil))

(defun inc-pos ()
  (if (null *possition*)
    (setf *possition* 0)
    (when (>= (incf *possition*) (length *menu*))
      (setf *possition* 0)))
  *possition*)

(defun dec-pos ()
  (if (null *possition*)
    (setf *possition* (1- (length *menu*)))
    (when (minusp (decf *possition*))
      (setf *possition* (1- (length *menu*)))))
  *possition*)

(defun current-song ()
  (nth *possition* *menu*))

(defun say-which ()
    (funcall (car (current-song))))

(defun up ()
  (when (null *playing-p*)
    (inc-pos)
    (say-which)))

(defun down ()
  (when (null *playing-p*)
    (dec-pos)
    (say-which)))

(defun enter ()
  (let
    ((cur (second (current-song))))
    (typecase cur
      (list
        (progn
          (setf *menu* cur)
          (init)
          (up)))
      (function
        (when (null *playing-p*)
          (setf *playing-p* t)
          (funcall cur))))))

(defun start ()
  (funcall *on-start*)
  (init)
  (up))

(defun get-process-command-function (menu &key on-start)
  (setf *menu* menu)
  (when on-start
    (setf *on-start* on-start))
  (lambda (line)
    (alexandria:switch (line :test #'equal)
      ("up" (up))
      ("down" (down))
      ("enter" (enter))
      ("start" (start))
      ("out" (format t "you are out of range~%")) 
      ("goodbye" (format t "Goodbye~%"))
      (otherwise
        (format t "UNKNOWN command \"~a\"~%" line)))))
