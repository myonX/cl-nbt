# Cl-Nbt
a library for generate minecraft-bedrock-nbt files

## examples
first of all,you have to bind `*nbt-output*`
please edit "output-file-path"
### compound , number and string tags
~~~ lisp
(with-open-file (cl-nbt:*nbt-output* "output-file-path"
                 :direction :output 
                 :element-type '(unsigned-byte 8)
                 :if-exists :supersede 
                 :if-does-not-exist :create)
                (tag-compound "" ((tag-byte "byte" 1)
                                  (tag-short "short" 1)
                                  (tag-integer "integer" 1)
                                  (tag-long "long" 1)
                                  (tag-float "float" 1.0)
                                  (tag-double "double" 1.0d0)
                                  (tag-string "string" "string"))))
~~~

### list tags
#### simple list
~~~lisp
(with-open-file (cl-nbt:*nbt-output* "output-file-path" 
                 :direction :output 
                 :element-type '(unsigned-byte 8) 
                 :if-exists :supersede 
                 :if-does-not-exist :create)
                (compound "" ((list "byte-list" (byte 1 2 3)))))
~~~

#### list in list
~~~lisp
(with-open-file (cl-nbt:*nbt-output* "output-file-path" 
                 :direction :output 
                 :element-type '(unsigned-byte 8) 
                 :if-exists :supersede 
                 :if-does-not-exist :create)
                (compound "" ((list "list-list" (list (byte 1 2 3) (byte 4 5 6))))))
~~~

#### empty list
~~~lisp
(with-open-file (cl-nbt:*nbt-output* "output-file-path" 
                 :direction :output 
                 :element-type '(unsigned-byte 8) 
                 :if-exists :supersede 
                 :if-does-not-exist :create)
                (compound "" ((list "empty-list" (byte )))))
~~~
or
~~~lisp
(with-open-file (cl-nbt:*nbt-output* "output-file-path" 
                 :direction :output 
                 :element-type '(unsigned-byte 8) 
                 :if-exists :supersede 
                 :if-does-not-exist :create)
                (compound "" ((list "empty-list" ()))))
~~~
#### 
~~~lisp
(with-open-file (cl-nbt:*nbt-output* "output-file-path" 
                 :direction :output 
                 :element-type '(unsigned-byte 8) 
                 :if-exists :supersede 
                 :if-does-not-exist :create)
                (compound "" ((list "compound-list" (compound ((tag-byte "byte" 1)) ((tag-integer "integer" 1)))))))

~~~

## Running Tests
~~~lisp
sbcl --load cl-nbt.asd \
     --eval "(ql:quickload :cl-nbt)"\
     --eval "(asdf:test-system :cl-nbt)"
~~~
## References
[bedrockwiki](https://wiki.bedrock.dev/nbt/nbt-in-depth)
