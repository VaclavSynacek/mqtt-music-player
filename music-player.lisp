(defpackage mqtt-music-player/music-player
  (:use
    :cl
    :mqtt-music-player/tts)
  (:export
    get-process-command-function))

(in-package mqtt-music-player/music-player)

(defvar *menu*)

(defvar *possition* nil)

(defvar *playing-p* nil)

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

(let
  ((sound (to-speech-wav "now playing selected peesnichcu")))
  (defun enter ()
    (when (null *playing-p*)
      (say-this sound)
      (setf *playing-p* t)
      (funcall (second (current-song))))))

(let
  ((sound (to-speech-wav "yakoou peesnichcu?")))
  (defun start ()
    (handler-case
      (uiop:run-program "killall mpv")
      (t () nil))
    (say-this sound)
    (init)
    (up)))


(defun get-process-command-function (menu)
  (setf *menu* menu)
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
