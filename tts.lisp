(defpackage mqtt-music-player/tts
  (:use :cl :uiop)
  (:export
    say-it-runtime
    to-speech-wav
    say-this
    speaker
    say))

(in-package mqtt-music-player/tts)


(handler-case
  (progn
    (uiop:run-program "pico2wave --usage"
                        :force-shell nil)
    (format t "pico2wave appears installed"))
  (t (original-condition)
     (format *error-output* "*********************************************************~%")
     (format *error-output* "You need to have pico2wave isntalled for tts.lisp to work~%")
     (format *error-output* "*********************************************************~%")
     (error original-condition)))


(defvar *tmp-file* "/tmp/tts.lisp.wav")

(defun say-it-runtime (line)
  (let
    ((run-it
       (format
         nil
         "pico2wave -w ~a \"~a\" && aplay ~a && rm ~a"
         *tmp-file* line *tmp-file* *tmp-file*)))
    (uiop:launch-program run-it)))

#|

(say-it-runtime "hello")

|#

(defun to-speech-wav (line)
  (prog2
    (uiop:run-program
      (format
        nil
        "pico2wave -w ~a \"~a\""
        *tmp-file* line))
    (alexandria:read-file-into-byte-vector *tmp-file*)                            
    (uiop:run-program (format nil "rm ~a" *tmp-file*))))


(defun say-this (wav)
  (uiop:run-program "aplay"
                    :input (lambda (strm)
                             (write-sequence wav strm))))

#|

(say-this (to-speech-wav "testing the speech configuration. you should hear sound."))

|#

(defmacro say (line)
  (let
     ((sound (gensym)))
     `(let
        ((,sound ,(to-speech-wav line)))
        (say-this ,sound)))) 

#|
 
(say "I am your father!")

|#


(defmacro speaker (line)
  (let
    ((sound (gensym)))
    `(let
       ((,sound ,(to-speech-wav line)))
       (lambda ()
         (say-this ,sound)))))

#|

(dotimes (i 3)
  (funcall (speaker "42")))

|#
