
(defparameter *shell* (uiop:launch-program "mosquitto_sub  -t command" :output :stream))


(defun say-it-runtime (line)
  (let
    ((run-it
       (format
         nil
         "pico2wave -w lookdave.wav \"~a\" && aplay lookdave.wav"
         line)))
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

;(say-this (to-spech-wav "testing test"))

(defparameter *favourites*
  `((,(to-spech-wav "cocolino") "mpv /home/pi/music/coccolino/*.mp3")
    (,(to-spech-wav "loeffler") "mpv \"/home/pi/music/Calle 13 - Multi Viral - MP3\/*.mp3\"")
    (,(to-spech-wav "kasee o") "mpv /home/pi/music/kase.o/*.mp3")))

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

(defun current-song ()
  (nth *possition* *favourites*))

(defun say-which ()
    (say-this (car (current-song))))

(defun up ()
  (inc-pos)
  (say-which))

(defun down ()
  (dec-pos)
  (say-which))

(let
  ((sound (to-spech-wav "now playing selected peesnichcu")))
  (defun enter ()
    (say-this sound)
    (uiop:launch-program (second (current-song)))))

(let
  ((sound (to-spech-wav "yakoou peesnichcu?")))
  (defun start ()
    (say-this sound)
    (init)))


(defun process-command (line)
  (let
    ((cmd (read-from-string line)))
    (case cmd
      ((UP DOWN ENTER START) (funcall cmd))
      ((OUT) (format t "you are out of range~%")) 
      ((GOODBYE) (format t "Goodbye~%"))
      (otherwise
        (format t "UNKNOWN command \"~a\"~%" cmd)))))

(defun start-listening ()
  (loop
    (let
      ((line (read-line (uiop:process-info-output *shell*))))
      (process-command line)
      (finish-output))))

(start-listening)
