
(defparameter *shell* (uiop:launch-program "mosquitto_sub  -t command" :output :stream))


(defun say-it (line)
  (let
    ((run-it
       (format
         nil
         "pico2wave -w lookdave.wav \"~a\" && aplay lookdave.wav"
         line)))
    (print run-it)
    (uiop:launch-program run-it)))
    

(say-it "hello")


(defun process-command (line)
  (let
    ((cmd (read-from-string line)))
    (case cmd
      ((UP DOWN) (say-it line))
      ((ENTER) (say-it "thank you for cooperation")
               (exit))
      ((OUT) (format t "you are out of range")) 
      (otherwise
        (format t "UNKNOWN command")
        (print cmd)))))

(loop
  (let
    ((line (read-line (uiop:process-info-output *shell*))))
    (process-command line)
    (finish-output)))
