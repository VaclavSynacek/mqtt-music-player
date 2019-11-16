(defpackage mqtt-music-player/tts
  (:use :cl :uiop)
  (:export
    say-it-runtime
    to-speech-wav
    say-this))

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
    
;(say-it-runtime "hello")

(defun slurp (infile)
  (with-open-file (instream infile
                   :direction :input
                   :element-type '(unsigned-byte 8)
                   :if-does-not-exist nil)
    (when instream
      (let*
        ((size (file-length instream))
         (result (make-array size :element-type '(unsigned-byte 8))))
        (read-sequence result instream :end size)
        result))))


(defun spit (outfile content)
  (with-open-file (outstream outfile
                    :direction :output
                    :element-type '(unsigned-byte 8)
                    :if-does-not-exist :create)
    (write-sequence content outstream)))


(defun to-speech-wav (line)
  (prog2
    (uiop:run-program
      (format
        nil
        "pico2wave -w ~a \"~a\""
        *tmp-file* line))
    (slurp *tmp-file*)                            
    (uiop:run-program (format nil "rm ~a" *tmp-file*))))

(let
  ((prev-stream nil))
  (defun say-this (wav)
    (when prev-stream
      (close prev-stream))
    (let
      ((aplay (uiop:launch-program "aplay" :input :stream)))
      (setf prev-stream (uiop:process-info-input aplay))
      (write-sequence wav prev-stream)
      "sent to aplay")))

;(say-this (to-speech-wav "testing the speech configuration. you should hear sound."))
