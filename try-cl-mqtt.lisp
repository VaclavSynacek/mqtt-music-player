(ql:quickload 'cl-async)

(ql:quickload :cl-mqtt)

(defpackage :mqtt-player
  (:use :cl :mqtt :bb))

(in-package :mqtt-player)


(defun test-it (host port)
  (bb:alet ((conn (mqtt:connect
                   host
                   :port port
                   :client-id "mqtt-player"
                   :on-message #'(lambda (message)
                                   (format t "~%RECEIVED: ~s~%"
                                           (babel:octets-to-string
                                            (mqtt:mqtt-message-payload message)
                                            :encoding :utf-8))))))
    (bb:walk
      (mqtt:subscribe conn "/a/#")
      (mqtt:subscribe conn "/b/#")
      (mqtt:publish conn "/a/b" "whatever1")
      (mqtt:unsubscribe conn "/a/#")
      (mqtt:publish conn "/a/b" "whatever2")
      (mqtt:publish conn "/b/c" "foobar")
      (as:with-delay (1)
        (mqtt:disconnect conn))))
  (values))

(as:with-event-loop ()
  (test-it "localhost" 1883))


(as:with-event-loop
  (:catch-app-errors t)
  (test-it "localhost" 1883))

