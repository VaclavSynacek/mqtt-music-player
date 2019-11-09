(defpackage mqtt-music-player/mosquitto-sub
  (:use :cl)
  (:export
    start-listening
    start-processing))

(in-package mqtt-music-player/mosquitto-sub)

(defvar *shell* nil)

(defun start-listening (topic)
  (when *shell*
    (uiop:close-streams *shell*)
    (uiop:terminate-process *shell*))
  (setf *shell*
        (uiop:launch-program
          (format nil "mosquitto_sub -h localhost -t ~a" topic)
          :output :stream)))

(defun start-processing (process-fn)
  (loop
    (let
      ((line (read-line (uiop:process-info-output *shell*))))
      (funcall process-fn line)
      (finish-output))))

#|
  
(start-listening "test")

(start-processing #'print)

; no publish to topic test and each message should get printed imediatelly

|#

