(defpackage cl-nbt/tests/main
  (:use :cl
        :cl-nbt
        :rove
   :alexandria
   :flexi-streams))
(in-package :cl-nbt/tests/main)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-nbt)' in your Lisp.

(defparameter *number-test-expected* #(10 0 0 1 4 0 98 121 116 101 1 2 5 0 115 104 111 114 116 1 0 3 7 0 105 110 116
  101 103 101 114 1 0 0 0 4 4 0 108 111 110 103 1 0 0 0 0 0 0 0 5 5 0 102 108
  111 97 116 0 0 128 63 6 6 0 100 111 117 98 108 101 0 0 0 0 0 0 240 63 8 6 0
                                       115 116 114 105 110 103 6 0 115 116 114 105 110 103 0))

(defparameter *list-test-expected* #(10 0 0 9 9 0 98 121 116 101 45 108 105 115 116 1 3 0 0 0 1 2 3 0))

(defparameter *list-list-test-expected* #(10 0 0 9 9 0 108 105 115 116 45 108 105 115 116 9 2 0 0 0 1 3 0 0 0 1 2 3 1 3
  0 0 0 4 5 6 0))

(defparameter *void-list-test-expected* #(10 0 0 9 9 0 118 111 105 100 45 108 105 115 116 0 0 0 0 0 0))

(defparameter *compound-list-test-expected* #(10 0 0 9 13 0 99 111 109 112 111 117 110 100 45 108 105 115 116 10 2 0 0 0 1
  4 0 98 121 116 101 1 0 3 7 0 105 110 116 101 103 101 114 1 0 0 0 0 0))


(defun tag->vector (tag)
  (flexi-streams:with-output-to-sequence (*nbt-output*
                                          :element-type '(unsigned-byte 8))
                                         (funcall tag)))

(deftest write-nbt
  (testing "number-tags-test"
    (ok (equalp *number-test-expected*
                (tag->vector (tag-compound "" (list (tag-byte "byte" 1)
                     (tag-short "short" 1)
                     (tag-integer "integer" 1)
                     (tag-long "long" 1)
                     (tag-float "float" 1.0)
                     (tag-double "double" 1.0d0)
                     (tag-string "string" "string")))))))
  (testing "list-tsg-test"
    (ok (equalp *list-test-expected* (tag->vector (tag-compound "" (list (tag-list "byte-list" '(byte 1 2 3))))))))
  (testing "list-list-test"
    (ok (equalp *list-list-test-expected*
                (tag->vector (tag-compound "" (list (tag-list "list-list" '(list (byte 1 2 3) (byte 4 5 6)))))))))
  (testing "void-list-test"
    (ok (equalp *void-list-test-expected*
                (tag->vector (tag-compound "" (list (tag-list "void-list" '(byte))))))))
  (testing "compound-list-test"
    (ok (equalp *compound-list-test-expected*
                (tag->vector (tag-compound "" (list (tag-list "compound-list"
                                                              (list 'compound (list (tag-byte "byte" 1))
                                                                    (list (tag-integer "integer" 1)))))))))))
;
(deftest parse-nbt
  (testing "number-tags-test"
    (ok (equalp '(tag-compound "" (list (tag-byte "byte" 1)(tag-short "short" 1)(tag-integer "integer" 1)(tag-long "long" 1)(tag-float "float" 1.0)(tag-double "double" 1.0d0)(tag-string "string" "string")))
                (flexi-streams:with-input-from-sequence (in *number-test-expected*)
                                                        (parse-tags in)))))
  (testing "list-tsg-test"
           (ok (equalp (flexi-streams:with-input-from-sequence (in *list-test-expected*)
                                                               (parse-tags in))
                       '(tag-compound "" (list (tag-list "byte-list" '(byte 1 2 3)))))))
  (testing "list-list-test"
           (ok (equalp
                (flexi-streams:with-input-from-sequence (in *list-list-test-expected*)
                                                        (parse-tags in))
                '(tag-compound "" (list (tag-list "list-list" '(list (byte 1 2 3) (byte 4 5 6))))))))
  (testing "void-list-test"
           (ok (equalp (flexi-streams:with-input-from-sequence (in *void-list-test-expected*)
                                                        (parse-tags in))
                '(tag-compound "" (list (tag-list "void-list" '(byte)))))))
  (testing "compound-list-test"
           (ok (equalp (flexi-streams:with-input-from-sequence (in *compound-list-test-expected*)                                                        
                                                        (parse-tags in))
                '(tag-compound "" (list (tag-list "compound-list"
                                                              (list 'compound (list (tag-byte "byte" 1))
                                                                    (list (tag-integer "integer" 1))))))))))
