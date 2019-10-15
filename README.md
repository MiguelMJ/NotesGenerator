# NotesGenerator
Lotes of syntax sugar for taking lecture notes in Latex.
***
Notes Generator (para anotaciones de clase y apuntes)
Para incluir algo en el preámbulo del documento LaTex, la primera línea de los apuntes debe ser #pre, y el fragmento debe cerrarse con #end

En LaTex hay algunos caracteres que hay que escapar obligatoriamente si no se está en modo matemático, como _ o $. NOG los escapa automáticamente (de momento sólo estos dos) en los contextos en los que es claro que deben escaparse.
Concretamente:

- '_': En todas partes fuera del modo matemático
- '$': Dentro de los nombres de temas, apartados y subapartados, conceptos señalados y snippets

OPCIONES DE NOG
---------------

- -a <author> Sets the author of the generated file. Overridable

- -t <title>  Sets the title of the generated file. Overridable

- -d          Prints the current date in the title

- -g          Prints the list of keywords at the end of the file.

- -f          Prints the list of FIXME at the end of the file.

PLANTILLA DE NOG
================
En modo texto
-------------
```
Tema
****
Apartado
========
Subapartado
-----------
**negrita**
__cursiva__
[[snippet]]
!!concepto señalado!!
_(Nota a pie de página)_

{*
- un elemento
- otro elemento
+ esto en negrita: esto ya no
+ nombre: descripcion
*}

{#
- un elemento numerado
- otro elemento numerado
+ sirve: dos puntos
+ tambien. uno solo
+ si no, hasta un salto de linea
#}

((FIXME)) Aquí va algo que requiere revisión en los apuntes

((code:lenguaje))
[{
codigo en lenguaje
}]
```
EN MODO MATEMÁTICAS (ENTRE $ o $$)
----------------------------------
```
función definida a trozos = {{
    caso primero \\
    caso segundo
}}

corchetes sintácticos [[ ]]
```
OTROS
-----
```
-> --> => ==>
<- <-- <= <==
<-> <--> <=> <==>
```
