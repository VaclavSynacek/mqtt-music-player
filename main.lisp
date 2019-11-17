(defpackage mqtt-music-player/main
  (:use
    :cl
    :mqtt-music-player/tts
    :mqtt-music-player/music-player
    :mqtt-music-player/mosquitto-sub))

(in-package mqtt-music-player/main)

(defvar *on-enter* (speaker "now playing selected peesnichcu"))

(defmacro play (song)
  `(lambda ()
     (funcall *on-enter*)
     (uiop:run-program ,(format nil "mpv ~a" song))))

(defun on-start ()
  (handler-case
    (uiop:run-program "killall mpv")
    (t () nil))
  (say "yakoou peesnichcu?"))


(defparameter *favourites*
  `((,(speaker "cocolino") ,(play "/home/pi/music/coccolino/*.mp3"))
    (,(speaker "loeffler") ,(play "/home/pi/music/the-best-of-christian-loeffler"))
    (,(speaker "saint germain") ,(play "/home/pi/terinka/Music/St\\ Germain/St.Germain\\ -\\ Boulevard/*.mp3"))
    (,(speaker "kasee o") ,(play "/home/pi/music/kase.o/*.mp3"))))

(start-listening "command")

(start-processing (get-process-command-function *favourites*
                                                :on-start #'on-start))
