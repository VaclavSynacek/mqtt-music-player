;;;; mqtt-music-player.asd

(asdf:defsystem #:mqtt-music-player
  :description
    "Music Player that can be controlled via MQTT protocol (for example from
     Arduino) and gives user feedback via text-to-speech."
  :author "Vaclav Synacek"
  :license  "MIT"
  :version "0.0.1"
  :depends-on ( "alexandria" )
  :serial t
  :components ((:file "tts")
               (:file "mosquitto-sub")
               (:file "music-player")
               (:file "main")))
