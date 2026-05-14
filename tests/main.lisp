(defpackage cl-nbt/tests/main
  (:use :cl
        :cl-nbt
        :rove))
(in-package :cl-nbt/tests/main)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-nbt)' in your Lisp.

(defun equal-binary-file (path-1 path-2)
  (with-open-file (path-1-in path-1 :direction :input :element-type '(unsigned-byte 8))
                  (with-open-file (path-2-in path-2 :direction :input :element-type '(unsigned-byte 8))
                  (let ((path-1-list (read-binary-sequence path-1-in))
                        (path-2-list (read-binary-sequence path-2-in)))
                       (equal path-1-list path-2-list)))))

(defun read-binary-sequence (stream &optional (list nil))
  (let ((result-byte (read-byte stream nil)))
       (if result-byte (read-binary-sequence stream (cons result-byte list))
                       (reverse list))))

(deftest tag-test
         (testing "number-tags-test"
                  (let ((expected-file-path "tests/test-file/number-test.nbt") (operator-output-path "tests/output/number-result.nbt"))
                    (with-open-file (cl-nbt::*nbt-output* operator-output-path :direction :output :element-type '(unsigned-byte 8) :if-exists :supersede :if-does-not-exist :create)
                                  (tag-compound "" ((tag-byte "byte" 1)
                                                    (tag-short "short" 1)
                                                    (tag-integer "integer" 1)
                                                    (tag-long "long" 1)
                                                    (tag-float "float" 1.0)
                                                    (tag-double "double" 1.0d0)
                                                    (tag-string "string" "string"))))
                    (ok (equal-binary-file expected-file-path operator-output-path))))
         (testing "list-tag-test"
                  (let ((expected-file-path "tests/test-file/list-test.nbt") (operator-output-path "tests/output/list-result.nbt"))
                    (with-open-file (cl-nbt::*nbt-output* operator-output-path :direction :output :element-type '(unsigned-byte 8) :if-exists :supersede :if-does-not-exist :create)
                                  (tag-compound "" ((tag-list "byte-list" (byte 1 2 3)))))
                    (ok (equal-binary-file expected-file-path operator-output-path))))
         (testing "list-list-test"
                  (let ((expected-file-path "tests/test-file/list-list-test.nbt") (operator-output-path "tests/output/list-list-test.nbt"))
                    (with-open-file (cl-nbt::*nbt-output* operator-output-path :direction :output :element-type '(unsigned-byte 8) :if-exists :supersede :if-does-not-exist :create)
                                  (tag-compound "" ((tag-list "list-list" (list (byte 1 2 3) (byte 4 5 6))))))
                    (ok (equal-binary-file expected-file-path operator-output-path))))
         (testing "void-list-test"
                  (let ((expected-file-path "tests/test-file/void-list-test.nbt") (operator-output-path "tests/output/void-list-test.nbt"))
                    (with-open-file (cl-nbt::*nbt-output* operator-output-path :direction :output :element-type '(unsigned-byte 8) :if-exists :supersede :if-does-not-exist :create)
                                  (tag-compound "" ((tag-list "void-list" (byte)))))
                    (ok (equal-binary-file expected-file-path operator-output-path)))))