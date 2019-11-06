
(defparameter *shell* (uiop:launch-program "mosquitto_sub  -t command" :output :stream))


(defun say-it-runtime (line)
  (let
    ((run-it
       (format
         nil
         "pico2wave -w lookdave.wav \"~a\" && aplay lookdave.wav"
         line)))
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


(defparameter *favourites*
  `(("cocolino" "xcowsay cocolino")
    ("loefflet" "xcowsay loeffler")
    ("calle trese" "xcowsay calle 13")))

(defvar *possition*)

(defun init ()
  (setf *possition* nil))

(defun inc-pos ()
  (if (null *possition*)
    (setf *possition* 0)
    (when (>= (incf *possition*) (length *favourites*))
      (setf *possition* 0)))
  *possition*)

(defun dec-pos ()
  (if (null *possition*)
    (setf *possition* (1- (length *favourites*)))
    (when (minusp (decf *possition*))
      (setf *possition* (1- (length *favourites*)))))
  *possition*)

(defun say-which ()
  (let
    ((which (nth *possition* *favourites*)))
    (uiop:launch-program (second which))))

(defun up ()
  (inc-pos)
  (say-which))

(defun down ()
  (dec-pos)
  (say-which))

(let
  ((sound (to-spech-wav "now playing selected peesnichcu")))
  (defun enter ()
    (say-this sound)))

(let
  ((sound (to-spech-wav "yakoou peesnichcu?")))
  (defun start ()
    (say-this sound)))

(defun process-command (line)
  (let
    ((cmd (read-from-string line)))
    (case cmd
      ((UP DOWN ENTER START) (funcall cmd))
      ((OUT) (format t "you are out of range~%")) 
      (otherwise
        (format t "UNKNOWN command \"~a\"~%" cmd)))))

(loop
  (let
    ((line (read-line (uiop:process-info-output *shell*))))
    (process-command line)
    (finish-output)))
