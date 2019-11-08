
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


(defun to-speech-wav (line)
  (uiop:run-program
    (format
      nil
      "pico2wave -w /tmp/mqtt-temp.wav \"~a\""
      line))
  (slurp "/tmp/mqtt-temp.wav"))                            

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

(defparameter *favourites*
  `((,(to-speech-wav "cocolino") "mpv /home/pi/music/coccolino/*.mp3")
    (,(to-speech-wav "loeffler") "mpv /home/pi/music/the-best-of-christian-loeffler")
    (,(to-speech-wav "saint germain") "mpv /home/pi/terinka/Music/St\\ Germain/St.Germain\\ -\\ Boulevard/*.mp3")
    (,(to-speech-wav "kasee o") "mpv /home/pi/music/kase.o/*.mp3")))

(defvar *possition*)

(defvar *playing-p*)

(defun init ()
  (setf *possition* nil)
  (setf *playing-p* nil))

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
      (uiop:launch-program (second (current-song))))))

(let
  ((sound (to-speech-wav "yakoou peesnichcu?")))
  (defun start ()
    (handler-case
      (uiop:run-program "killall mpv")
      (t () nil))
    (say-this sound)
    (init)
    (up)))


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
  (init)
  (loop
    (let
      ((line (read-line (uiop:process-info-output *shell*))))
      (process-command line)
      (finish-output))))


(start-listening)
