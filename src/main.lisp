(uiop:define-package cl-nbt
  (:use #:cl
        #:nibbles
        #:babel)
  (:export :tag-byte
           :tag-short
           :tag-integer
           :tag-long
           :tag-float
           :tag-double
           :tag-string
           :tag-list
           :tag-compound
           :nbt-write-byte
           :nbt-write-short
           :nbt-write-integer
           :nbt-write-long
           :nbt-write-float
           :nbt-write-double
           :nbt-write-string
           :nbt-write-list
           :nbt-write-compound
           :*nbt-output*
           :serialize-tags
           :parse-tags))
(in-package #:cl-nbt)

(defvar *nbt-output*)


(defparameter *tag-type-number-alist* '((tag-compound . 10) (tag-list . 9) (tag-string . 8) (tag-byte . 1) (tag-short . 2) (tag-integer . 3) (tag-long . 4) (tag-float . 5) (tag-double . 6)))

;; 非共通部分
(defmacro define-io-operators-that-bind-a-stream-to-*nbt-output* (new-function-name function)
  `(defun ,new-function-name (number)
      (,function number *nbt-output*)))

(define-io-operators-that-bind-a-stream-to-*nbt-output* nbt-write-byte write-byte)

(define-io-operators-that-bind-a-stream-to-*nbt-output* nbt-write-short nibbles:write-sb16/le)

(define-io-operators-that-bind-a-stream-to-*nbt-output* nbt-write-integer nibbles:write-sb32/le)

(define-io-operators-that-bind-a-stream-to-*nbt-output* nbt-write-long nibbles:write-sb64/le)

(define-io-operators-that-bind-a-stream-to-*nbt-output* nbt-write-float nibbles:write-ieee-single/le)

(define-io-operators-that-bind-a-stream-to-*nbt-output* nbt-write-double nibbles:write-ieee-double/le)

(defun nbt-write-string (string)
  (nbt-write-short (length string))
  (write-sequence (babel:string-to-octets string :encoding :utf-8) *nbt-output*))

(defun nbt-write-compound (list)
  (dolist (thunk list)
          (funcall thunk))
  (nbt-write-byte 0))

(defun nbt-write-list (list)
  (if (cdr list)
      (nbt-write-byte (cdr (assoc (concatenate-symbol 'tag- (car list)) *tag-type-number-alist*)))
      (nbt-write-byte 0))
  (nbt-write-integer (length (cdr list)))
  (let ((write-operator (concatenate-symbol 'nbt-write- (car list))) (rest-list (cdr list)))
       (mapc (lambda (x) (funcall write-operator x)) rest-list)
       ))

(defun write-tag-helper (&key tag-type tag-name-string)
  (nbt-write-byte (cdr (assoc tag-type *tag-type-number-alist*)))
  (nbt-write-string tag-name-string))

;Alexandriaのformat-symbolでいいね
(eval-when (:compile-toplevel :load-toplevel :execute)
           (defun concatenate-symbol (symbol-1 symbol-2)
             (intern (concatenate 'string (symbol-name symbol-1) (symbol-name symbol-2))
                     (symbol-package symbol-1))))


#|
(define-tag byte)
->
(defun tag-byte (tag-name-string data)
  (write-tag-helper :tag-type byte :tag-name-string tag-name-string)
  (nbt-write-byte data))
|#

(defmacro define-tag (tag-name)
  (let ((tag-type (concatenate-symbol 'tag- tag-name))
        (nbt-write-type (concatenate-symbol 'nbt-write- tag-name)))
    `(defun ,tag-type (tag-name-string data)
       (lambda () (write-tag-helper :tag-type ',tag-type :tag-name-string tag-name-string)
                  (,nbt-write-type data)))))

(define-tag byte)

(define-tag short)

(define-tag integer)

(define-tag long)

(define-tag float)

(define-tag double)

(define-tag string)

(define-tag list)

(define-tag compound)

;;;parse
;listって引数名悪い
(defun parser-helper (type-num tag-name list)
  (list
          (car (rassoc type-num *tag-type-number-alist*))
          tag-name
          list))

(defun read-unicode-string (stream nbytes)
       (let ((buf (nibbles:make-octet-vector nbytes)))
            (read-sequence buf stream)
            (babel:octets-to-string buf :encoding :utf-8)))

(defun parse-string (binary-stream)
  (let ((string-length (nibbles:read-sb16/le binary-stream)))
    (read-unicode-string binary-stream string-length)))

;;;
(defun serialize-tags (path tags)
  (with-open-file (*nbt-output* path
    :direction :output
    :element-type '(unsigned-byte 8)
    :if-exists :supersede
    :if-does-not-exist :create)
    (funcall tags)))

(defmacro ten-case (num zero-form one-form two-form three-form four-form five-form six-form seven-form eight-form nine-form ten-form)
          `(case ,num
                 (0 ,zero-form)
                 (1 ,one-form)
                 (2 ,two-form)
                 (3 ,three-form)
                 (4 ,four-form)
                 (5 ,five-form)
                 (6 ,six-form)
                 (7 ,seven-form)
                 (8 ,eight-form)
                 (9 ,nine-form)
                 (10 ,ten-form)))

(defun parse-compound (binary-stream)
       )

(defun parse-tags (binary-stream &optional (type-number (read-byte binary-stream)))
       (ten-case type-number
              ()
              (parser-helper 1
                             (parse-string binary-stream)
                             (read-byte binary-stream))
              (parser-helper 2
                             (parse-string binary-stream)
                             (nibbles:read-sb16/le binary-stream))
              (parser-helper 3
                             (parse-string binary-stream)
                             (nibbles:read-sb32/le binary-stream))
              (parser-helper 4
                             (parse-string binary-stream)
                             (nibbles:read-sb64/le binary-stream))
              (parser-helper 5
                             (parse-string binary-stream)
                             (nibbles:read-ieee-single/le binary-stream))
              (parser-helper 6
                             (parse-string binary-stream)
                             (nibbles:read-ieee-double/le binary-stream))
              ()
              (parser-helper 8
                             (parse-string binary-stream)
                             (parse-string binary-stream))
              ()
              (parser-helper 10
                             (parse-string binary-stream)
                             (cons 'list
                                   (loop for tag-byte-num = (read-byte binary-stream)
                                         until (zerop tag-byte-num)
                                         collect (parse-tags binary-stream tag-byte-num))))))
