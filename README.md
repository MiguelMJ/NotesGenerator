# NotesGenerator
Lotes of syntax sugar for taking lecture notes in Latex.
***
#### Contents

***
### What is NOG?
LaTex is pretty, we can all agree in that. But taking notes in LaTex can be really tedious, too. NOG is a way to simplify this process. It's a pseudo-language which compiles to latex, and then to pdf. It is intended to be some kind of medium point between markdown and latex, something easy to write but extensible and customizable.

### Dependencies
- pdflatex 
- Some LaTex packages (check them in the nog.sh file)
 
### Usage
`nog [options] <input_files>`

 Options | Description 
---|---
`-a <author>`| Sets the author of the notes
`-t <title>`| Sets the title of the notes. Default is 'Notes'
`-d <date>`| Sets the author of the notes
`-o <output_file>`| Specifies name of output file. Default is 'Notes.pdf'
`-s, --save`| Saves all temporal files (including the `.tex`) in a directory called`nogtemp`
`-g`| Adds an appendix with the glossary
`-f`| Adds an appendix with the list of fixme
`-k <seconds>`| Sets how much to wait until killing `pdflatex` if it doesn't compile
`-l <language>`| Sets the language for the package `babel`

### How does it work
#### No more escaping for these
There are some characters in LaTex that must be escaped when not in math mode. NOG escapes them in the context where it is clear that they must be escaped:
- `_` is escaped everywhere outside math mode.
- `$` is escaped within the name of units, subunits and subsubunits, keywords and snippets.(see below)
#### New sectioning
```
Unit
****
Unit section
============
Unit subsection
---------------
```
When any of the following is used, the table of contents is automatically generated, to the unit section level. Then, at the beginning of each unit, another table of contents of that particular unit is generated to the level of unit subsection.
#### Emphasis
```
**bold**
__italic__
!!keyword!!
```
Keywords not only make the word bold, but have a hand glyph pointing to them in the margin and are included in the glossary, if the `-g` option is used. 

#### Footnotes
```
_(footnote)_
```
Footnotes use arabic numbers, restarting in each page.
#### Lists
Lists can use bullets, when specified between `{*` and `*}`; numbers, when specidied between `{#` and `#}`; or none of them, when specified between `{.` and `.}`.

Then, each item can be pointed with `-`, with no other efect than writting he bullet or number, or with `+`, in wich case the text will be bold until a `.`, `:` or a new line.

#### Code
```
    `inline code`
    ```<br>
    Code without syntax highlight
    ```
    ```<language>
    Code with syntax highlight
    ```
```

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
En modo matemáticas (entre $ o $$)
----------------------------------
```
función definida a trozos = {{
    caso primero \\
    caso segundo
}}

corchetes sintácticos [[ ]]
```
Otros
-----
```
-> --> => ==>
<- <-- <= <==
<-> <--> <=> <==>
```
### To Do
- First of all, this documentation needs to be improved, starting by translating all to english.
- Then, there should be some examples included, so I'll try to upload som in coming updates.
- And of course, rearrange the contents of this readme file and go deeper into details, but, yes, time.
- Also, here's a list of features pending to be implemented
    - tables
    - multicolumn text
    - boxed text
    - graphs/trees(? maybe some automatic tikz stuff)

