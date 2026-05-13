(defsystem "cl-nbt"
  :version "0.0.1"
  :author ""
  :license ""
  :depends-on ("nibbles" "babel")
  :components ((:module "src"
                :components
                ((:file "main"))))
  :description ""
  :in-order-to ((test-op (test-op "cl-nbt/tests"))))

(defsystem "cl-nbt/tests"
  :author ""
  :license ""
  :depends-on ("cl-nbt"
               "rove")
  :components ((:module "tests"
                :components
                ((:file "main"))))
  :description "Test system for cl-nbt"
  :perform (test-op (op c) (symbol-call :rove :run c)))
