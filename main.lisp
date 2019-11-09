(format t "baf from main")



(defpackage mqtt-music-player/main
  (:use
    :cl
    :mqtt-music-player/tts
    :mqtt-music-player/music-player
    :mqtt-music-player/mosquitto-sub))

(in-package mqtt-music-player/main)




(defparameter *favourites*
  `((,(to-speech-wav "cocolino") "mpv /home/pi/music/coccolino/*.mp3")
    (,(to-speech-wav "loeffler") "mpv /home/pi/music/the-best-of-christian-loeffler")
    (,(to-speech-wav "saint germain") "mpv /home/pi/terinka/Music/St\\ Germain/St.Germain\\ -\\ Boulevard/*.mp3")
    (,(to-speech-wav "kasee o") "mpv /home/pi/music/kase.o/*.mp3")))


(start-listening "command")

(start-processing (get-process-command-function *favourites*))
