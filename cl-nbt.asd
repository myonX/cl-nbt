(defsystem "cl-nbt"
  :version "0.0.1"
  :author "myon_X"
  :license "MIT"
  :depends-on ("nibbles" "babel")
  :components ((:module "src"
                :components
                ((:file "main"))))
  :description "this library provides simple ways to create Minecraft Bedrock NBT files"
  :in-order-to ((test-op (test-op "cl-nbt/tests"))))

(defsystem "cl-nbt/tests"
  :author "myon_X"
  :license "MIT"
  :depends-on ("cl-nbt"
               "rove"
               "alexandria"
               "flexi-streams")
  :components ((:module "tests"
                :components
                ((:file "main"))))
  :description "Test system for cl-nbt"
  :perform (test-op (op c) (symbol-call :rove :run c)))
