(defpackage cl-nbt/tests/main
  (:use :cl
        :cl-nbt
        :rove
        :alexandria))
(in-package :cl-nbt/tests/main)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-nbt)' in your Lisp.

(defun equal-binary-file (path-1 path-2)
  (equalp (alexandria:read-file-into-byte-vector (xxx->cl-nbt/xxx path-1))
          (alexandria:read-file-into-byte-vector (xxx->cl-nbt/xxx path-2))))

(defun xxx->cl-nbt/xxx (relative-path)
  (uiop:subpathname (asdf:system-source-directory :cl-nbt) relative-path))

(defmacro tag-testing (testing-word expected-file-path operator-output-path tag)
  `(testing ,testing-word
     (progn (cl-nbt:serialize-tags (xxx->cl-nbt/xxx ,operator-output-path)
                                   ',tag)
            (ok (equal-binary-file ,expected-file-path ,operator-output-path)))))

(defmacro def-tag-test (test-name &rest rest)
  `(deftest ,(quote test-name) ,@(mapcar (lambda (element) (macroexpand-1 `(tag-testing ,@element))) rest)))

(def-tag-test tag-test
  ("nubmer-tags-test"
   "tests/test-file/number-test.nbt"
   "tests/output/number-result.nbt"
   (tag-compound "" ((tag-byte "byte" 1)
                     (tag-short "short" 1)
                     (tag-integer "integer" 1)
                     (tag-long "long" 1)
                     (tag-float "float" 1.0)
                     (tag-double "double" 1.0d0)
                     (tag-string "string" "string"))))
  ("list-tag-test"
   "tests/test-file/list-test.nbt"
   "tests/output/list-result.nbt"
   (tag-compound "" ((tag-list "byte-list" (byte 1 2 3)))))
  ("list-list-test"
   "tests/test-file/list-list-test.nbt"
   "tests/output/list-list-test.nbt"
   (tag-compound "" ((tag-list "list-list" (list (byte 1 2 3) (byte 4 5 6))))))
  ("void-list-test"
   "tests/test-file/void-list-test.nbt"
   "tests/output/void-list-test.nbt"
   (tag-compound "" ((tag-list "void-list" (byte)))))
  ("compound-list-test"
   "tests/test-file/compound-list.nbt"
   "tests/output/compound-list-test.nbt"
   (tag-compound "" ((tag-list "compound-list"
                               (compound ((tag-byte "byte" 1))
                                         ((tag-integer "integer" 1))))))))
