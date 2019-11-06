
(defparameter *shell* (uiop:launch-program "mosquitto_sub  -t command" :output :stream))


(defun say-it-runtime (line)
  (let
    ((run-it
       (format
         nil
         "pico2wave -w lookdave.wav \"~a\" && aplay lookdave.wav"
         line)))
    (print run-it)
    (uiop:launch-program run-it)))
    

(say-it-runtime "hello")


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


(defun to-spech-wav (line)
  (uiop:run-program
    (format
      nil
      "pico2wave -w /tmp/mqtt-temp.wav \"~a\""
      line))
  (slurp "/tmp/mqtt-temp.wav"))                            


(defun say-this (wav)
  (let
    ((aplay (uiop:launch-program "aplay" :input :stream)))
    (write-sequence wav (uiop:process-info-input aplay))
    "sent to aplay"))


(defun process-command (line)
  (let
    ((cmd (read-from-string line)))
    (case cmd
      ((UP DOWN) (say-it-runtime line))
      ((ENTER) (say-it-runtime "thank you for cooperation")
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
