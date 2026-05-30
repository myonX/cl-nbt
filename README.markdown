# Cl-Nbt
a library to  generate minecraft-bedrock-nbt files

## examples

please edit "output-file-path"
### compound , number and string tags
~~~ lisp
(cl-nbt:serialize-tags "output-file-path"
                       (tag-compound "" (list (tag-byte "byte" 1)
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
(cl-nbt:serialize-tags "output-file-path"
                       (tag-compound "" (list (tag-list "byte-list" '(byte 1 2 3)))))
~~~

#### list in list
~~~lisp
(cl-nbt:serialize-tags "output-file-path"
                       (tag-compound "" (list (tag-list "list-list" '(list (byte 1 2 3) 
                                                                           (byte 4 5 6))))))
~~~

#### empty list
~~~lisp
(cl-nbt:serialize-tags "output-file-path"
                       (tag-compound "" (list (tag-list "void-list" '(byte)))))
~~~
or
~~~lisp
(cl-nbt:serialize-tags "output-file-path"
                       (tag-compound "" (list (tag-list "void-list" '()))))
~~~
#### compound list
~~~lisp
(cl-nbt:serialize-tags "output-file-path"
                       (tag-compound "" (list (tag-list "compound-list"
                                                        (list 'compound (list (tag-byte "byte" 1))
                                                                        (list (tag-integer "integer" 1)))))))
~~~

## Running Tests
~~~lisp
sbcl --load cl-nbt.asd \
     --eval "(ql:quickload :cl-nbt)"\
     --eval "(asdf:test-system :cl-nbt)"
~~~
## References
[bedrockwiki](https://wiki.bedrock.dev/nbt/nbt-in-depth)
