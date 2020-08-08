# NOG - Notes Generator
Flex, Bash and PDFLaTex to take easy beautiful notes.
***
#### Contents

- [What is NOG?](#what-is-nog)
  - [And why not just markdown and pandoc?](#and-why-not-just-markdown-and-pandoc)
- [Usage](#usage)
- [Build NOG](#build-nog)
- [Configuration file](#configuration-file)
- [Features](#features)
  - [Escaping](#escaping)
  - [Indentation](#indentation)
  - [Sectioning with Units](#sectioning-with-units)
  - [Emphasis](#emphasis)
  - [Footnotes](#footnotes)
  - [Lists](#lists)
  - [Code](#code)
  - [Fixmes](#fixmes)
  - [Keywords](#keywords)
  - [LaTex preamble](#latex-preamble)
  - [LaTex commands](#latex-commands)
  - [Symbol substitution](#symbol-substitution)
- [To do](#to-do)
- [License](#license)

## What is NOG?

LaTex is pretty, we can all agree in that. But taking notes in LaTex can be really tedious, too. NOG is a way to simplify this process. It's a pseudo-language which compiles to latex, and then to pdf. It is intended to be some kind of medium point between markdown and latex, something easy to write but extensible and customizable.

### And why not just markdown and pandoc?

Writing notes in markdown and translating to LaTex with pandoc is great, and you should also try it. But NOG doesn't intend to be a format translator. Its purpose is to both simplify part of the LaTex syntax and unify some aspects that may require some boilerplate LaTex code, like the section tocs or the glossary, for example.

And, of course, another equally important reason is the possibility of extending NOG with new rules in Flex or LaTex commands. In the end the idea is to have nicer results with less typing.

## Usage

`nog [options] <input_files>`

 Options | Description 
---|---
`-h`| Display a help message and exit. 
`-v`| Display the version of the software and exit. 
`-c`| Generate a [configuration file](#configuration-file) and exit. 
`-a <author>`| Set the author of the notes. It is empty by default. 
`-t <title>`| Set the title of the notes. It is 'Notes' by default. 
`-d `| Omit the date in the title. 
`-o <output_file>`| Specify name of output file without the. pdf extension. It is 'Notes' by default (produces 'Notes.pdf'), 
`-g`| Add an appendix with the glossary. 
`-f`| Add an appendix with the list of fixme. 
`-k <seconds>`| Set how much to wait until killing `pdflatex` if it doesn't compile. 
`-l <language>`| Set the language for the package `babel`. 
`-s, --save`| Save all temporal files (including the .tex) in a directory called`nogtemp`. 
`--only-tex`|Do not generate the .pdf, only the .tex file. Invalidates the `--also-tex` option.
`--also-tex`|Generate the .tex, besides the .pdf file. It has no effect with the `--only-tex` option.
## Build NOG

The three targets of the makefile are quite straightforward: 

- `make all` to compile the binaries.
- `sudo make install` to install the binaries.
- `make doc` to compile the man page.
- `sudo make install-doc` to install the man page.
- `sudo make uninstall`  to uninstall the binaries and the man page.

If you want to install NOG:

```
$ cd path/to/the/project
$ sudo make install
...
$ nog -v
nog v1.2
```

If you just want to build it, without installing:

```
$ cd path/to/the/project
$ make
...
$ ./nog -v
nog v1.2
```

## Configuration file

If `nog` is run in a directory that contains a `.nogconfig` file, then uses the values specified in it as options. Nonetheless, **options passed via command line will override the ones found in the command line**.

The options of the `.nogconfig` are case insensitive and empty values are ignored.

[`nog -c`](#usage) generates a `.nogconfig` file, if there is none in the working directory.

| Configuration          | Description                       |
| ---------------------- | --------------------------------- |
| `input=<file>`         | Equivalent to `nog <file>`.       |
| `title=<title>`        | Equivalent to `nog -t <title>`.   |
| `author=<author>`      | Equivalent to `nog -a <author>`.  |
| `date=<date>`          | Equivalent to `nog -d <date>`.    |
| `file=<file>`          | Equivalent to `nog -o <file>`.    |
| `glossary=yes`         | Equivalent to `nog -g.`           |
| `glossary_name=<name>` | Set the name of the glossary.     |
| `fixme=yes`            | Equivalent to `nog -f`.           |
| `fixme_name=<name>`    | Set the name of the fixme list.   |
| `timeout=<seconds>`    | Equivalent to `nog -k <seconds>`. |
| `language=<lang>`      | Equivalent to `nog -l <lang>`.    |
| `save=yes`             | Equivalent to `nog -s` .          |
| `only_tex=yes`         | Equivalent to `nog --only-tex`.   |
| `also_tex=yes`         | Equivalent to `nog --also-tex.`   |

## Features

The files passed to the `nog` command are processed in order, so you could think of them as a single concatenated file. Their content are passed to the body of the LaTex document.

### Escaping

There are some characters in LaTex that must be escaped when not in math mode. NOG escapes them in the context where it is clear that they must be escaped:
- `_` is escaped everywhere outside math mode.
- `$` is escaped within the name of units, unit sections and unit subsections, keywords and snippets.(see below)
### Indentation

In my opinion, the way LaTex handles indentation can be sometimes capricious. NOG gives control to the user, with a simple rule. A new line is indented only if starts with a white space.

```
This line won't be indented.
This line won't, either.
 This one will be indented.
   This one too, with the same space as the one above, even though I have used more whitespaces here.
```



### Sectioning with Units

To keep it simple, NOG uses just three levels of sectioning: _Unit_, _Unit section_ and _Unit subsection_. The main Table of Contents contains just the Units, and each Unit contains another ToC with its unit sections and unit subsections.

```
Unit
****
Unit section
============
Unit subsection
---------------
```
### Emphasis

Double asterisks for bold text and double underscore for italic test to mark keywords.

```
**bold**
__italic__
```
### Footnotes

Footnotes use arabic numbers, restarting in each page.

```
_(footnote)_
```
### Lists

Lists between `{*` and `*} `use bullets.

Lists between `{#` and `#} `use numbers.

Lists between `{.` and `.}` use none.

Items starting with `-` are normal items.

items starting with `+` start with bold text until a dot (`.`), a colon (`:`) or a new line.

```
{*
- first item
- second item
+ important: this is another item
*}
```

### Code

The insertion of code works the same way as in markdown.
```
	`code word`
    '''[language]
    code block
    '''
```
_Note_: For format reasons I've used  ''' , but the correct way is \`\`\`.

#### External code

You can insert code directly from a file with the following syntax:

````
'''file:<path/to/file>[:language]
'''
````

_Note_: For format reasons I've used  ''' , but the correct way is \`\`\`.

### Fixmes

Also, a list of incomplete or wrong parts can be added. For this purpose you can just insert `((FIXME))` to any point of the document, and a link to it will be added in an optional appendix (see [`-f` option](#usage)).

```
((FIXME)) Complete this section
((FIXME)) Correct this formula
```

### Keywords

Keywords are marked by two exclamation signs. They are  appear in bold text and have a hand glyph pointing at them in the margin of the page. A link to them is added in an optional appendix (see [`-g` option](#usage)).

```
!!keyword!!
```

_Note_: Keywords doesn't support non ascii characters.

### LaTex preamble

Everything included between the lines  `#pre` and `#end` will be included in the preamble of the LaTex document.

``` 
#pre
\usepackage{amssymb}
#end
```

### LaTex commands

Latex commands can be used normally inside the notes.

```
\begin{center}
This text is centered.
\end{center}
The equation is $E=mc^2$
```

### Symbol substitution

NOG also makes some substitution to commonly used symbols that would be easier to write and understand in a graphical way.

#### Arrows (Text and math mode)

```
-> --> => ==>
<- <-- <= <==
<-> <--> <=> <==>
```
#### Function defined by parts (Math mode)

```
$$
abs(x) = {{
	-x & if x < 0 \\
	 x & otherwise
}}
$$
```
#### Other

- `>` and `<` in text mode are translated to `$>$ and `$<$`.
- `¬` is now translated to`$\neg$` in text mode and`\neg` in math mode. 

## Tips

Currently is not easy to find an error in the LaTex code produced by NOG. If you only use the features of NOG without direct LaTex commands, this wouldn't be a problem. But if you make mild or heavy use of LaTex in your notes, you may want to use the [`--only-tex` option](#usage) or the [`only_tex=yes` configuration](#configuration-file) and then use a LaTex editor of your choice.

## To do

- List of features pending to be implemented (although they can currently be done via LaTex commands):
    - Hyperlinks
    - Tables
    - Multicolumn text
    - Boxed text
    - Graphs/Trees (maybe automatize tikz)

## License

NOG is licensed under the GPL-3.0 License.