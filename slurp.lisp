
(defun slurp (infile)
  (with-open-file (instream infile
                   :direction :input
                   :element-type '(unsigned-byte 8)
                   :if-does-not-exist nil)
    (when instream
      (let*
        ((size (file-length instream))
         (result (make-array size :element-type '(unsigned-byte 8))))
        (read-sequence result instream :end size)))))


(defun spit (outfile content)
  (with-open-file (outstream outfile
                    :direction :output
                    :element-type '(unsigned-byte 8)
                    :if-does-not-exist :create)
    (write-sequence content outstream)))


#|
(defvar binfile)

(progn
  (setf binfile (slurp "~/htop.core"))
  "Done")

(length binfile)

(progn
  (spit "~/htop.core.bckp" binfile)
  "Copied")
|#
