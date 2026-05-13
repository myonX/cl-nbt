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
           :nbt-write-compound))
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
  (dolist (tag-form list)
    (eval tag-form))
  (nbt-write-byte 0))

(defun macro-mapc (operator-symbol list)
  (dolist (x list list) (eval `(,operator-symbol ,x))))

(defun nbt-write-list (list)
  (nbt-write-byte (cdr (assoc (concatenate-symbol 'tag- (car list)) *tag-type-number-alist*)))
  (nbt-write-integer (length (cdr list)))
  (let ((write-operator (concatenate-symbol 'nbt-write- (car list))) (rest-list (cdr list)))
       (macro-mapc write-operator rest-list)
       ))

(defun write-tag-helper (&key tag-type tag-name-string)
  (nbt-write-byte (cdr (assoc tag-type *tag-type-number-alist*)))
  (nbt-write-string tag-name-string))

;Alexandriaのformat-symbolでいいね
(eval-when (:compile-toplevel :load-toplevel :execute)
           (defun concatenate-symbol (symbol-1 symbol-2)
                  (intern (concatenate 'string (symbol-name symbol-1) (symbol-name symbol-2)))))
#|
(define-tag byte)
->
(DEFMACRO TAG-BYTE (TAG-NAME-STRING DATA &REST REST)
  `(progn (WRITE-NBT-HELPER :TAG-TYPE 'TAG-BYTE :TAG-NAME-STRING ,TAG-NAME-STRING)
          (NBT-WRITE-BYTE DATA ,@rest)))
|#
#|
(define-tag byte)
->
(defun tag-byte (tag-name-string data)
  (write-tag-helper :tag-type byte :tag-name-string tag-name-string)
  (nbt-write-byte data))
|#

#|
(defmacro define-tag (tag-name)
  (let ((tag-type (concatenate-symbol 'tag- tag-name)) (nbt-write-type (concatenate-symbol 'nbt-write- tag-name)))
      `(defmacro ,tag-type (tag-name-string data)
          `(progn (write-tag-helper :tag-type ,',tag-type :tag-name-string ,,'tag-name-string)
                  (,',nbt-write-type ',,'data)))))
|#

(defmacro define-tag (tag-name)
  (let ((tag-type (concatenate-symbol 'tag- tag-name)) (nbt-write-type (concatenate-symbol 'nbt-write- tag-name)))
      `(defun ,tag-type (tag-name-string data)
          (write-tag-helper :tag-type ',tag-type :tag-name-string tag-name-string)
          (,nbt-write-type data))))

(define-tag byte)

(define-tag short)

(define-tag integer)

(define-tag long)

(define-tag float)

(define-tag double)

(define-tag string)
#|
(define-tag list)

(define-tag compound)
|#

(defmacro tag-list (tag-name-string list)
  `(progn (write-tag-helper :tag-type 'tag-list :tag-name-string ,tag-name-string)
          (nbt-write-list (quote ,list))))

(defmacro tag-compound (tag-name-string tag)
  `(progn (write-tag-helper :tag-type 'tag-compound :tag-name-string ,tag-name-string)
          (nbt-write-compound (quote ,tag))))

#|
(with-open-file (cl-nbt::*nbt-output* "tmp.bin" :direction :output :element-type '(unsigned-byte 8))
  (cl-nbt::tag-list "list" '(1 2 3) :element-type byte))
|#