# Cl-Nbt
this 
## Usage
~~~ lisp
(compound ""
           ((byte "" 1)
            (short "" 1)
            (integer "" 1)
            (long "" 1)
            (float "" 1.0)
            (double "" 1.0d0)
            (list "" (string "this" "is" "string" "list"))
            (string "" "string")))
~~~

~~~lisp
(compound "" ((list "byte-list" (byte 1 2 3))))
~~~

~~~
(compound "" ((list "list-list" ('tag-list ('tag-byte 1 2 3) ('tag-byte 4 5 6)))))
~~~

## Installation
## debug

