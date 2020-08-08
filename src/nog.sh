#!/bin/bash
version="nog v1.2 (dev0)"
usage='Usage: nog [OPTIONS] [FILES]
Reads in order a list of files and generate a pdf file via pdflatex.

-h
    Display this help message.
-v
    Display the software version.
-a author
    Set the author of the notes.
-t title
    Set the title of the notes.
-d  
    Add the date to the generated notes.
-o file
    Name of the output file without the .pdf extension.
-g  
    Add an appendix with the glossary.
-f  
    Add an appendix with the list of fixme.
-k timeout
    Kill pdflatex after timeout seconds, if it doesn'"'"'t compile.
-l language
    Sets the language for the LaTex package babel.
-s, --save
    Save all the temporal files, including the .tex.
--only-tex
    Do not generate the .pdf, only the .tex file.
--also-tex
    Generate the .tex, besides the .pdf.
'
defaultconfigfile='# NOG v1.2
INPUT=
TITLE=Notes
AUTHOR=
DATE=
FILE=Notes
GLOSSARY=NO
GLOSSARY_NAME=KEY WORDS
FIXME=NO
FIXME_NAME=FIXME
TIMEOUT=5
LANGUAGE=english
SAVE=NO
ONLY_TEX=NO
ALSO_TEX=NO
'
##
# FUNCTION TO READ CONFIGURATION FILE.
##
config(){
    val=$(grep -Ei "^$1=" .nogconfig 2>/dev/null | head -n 1 | cut -d '=' -f 2-)
    printf "%s" "$val"
    [ ! -z "$val" ]
    return $?
}
##
# FUNCTION TO ADD INPUT FILE TO ARGUMENTS.
##
declare files
addfile(){
    files="$files $(printf %q "$*")"
}

##
# ASSIGN VALUES TO THE PARAMETERS, BY CONFIGURATION OR DEFAULT.
##
title="$(config title || echo "Notes")"
author="$(config author)"
date="\\date{$(config date)}"
file="$(config file || echo $title)"
preappendices=""
glossary="$(config glossary)"
glossary_name="$(config glossary_name || echo KEY WORDS)"
fixmelist="$(config fixme)"
fixmelist_name="$(config fixme_name || echo FIXME)"
timeout="timeout $(config timeout || echo 5)"
language="$(config language || echo english)"
language=${language,,}
save="$(config save)"
input="$(config input)"
only_tex="$(config only_tex)"
also_tex="$(config also_tex)"
if [ -z "$input" ]; then
    echo -e "$version\n$usage"
    exit 2
else
    addfile $input
fi
##
# PARSE ARGUMENTS. ARGUMENTS THAT ARE NOT OPTIONS (DOESN'T START WITH 
# HYPEN) ARE CONSIDERED INPUT FILES. THESE OPTIONS MAY OVERRIDE VALUES
# FROM THE CONFIGURATION FILE.
##
while [ $# -ne 0 ]
do
    case "$1" in 
    -v)
        echo "$version"
        exit 0
    ;;
    -h)
        echo "$usage"
        exit 0
    ;;
    -l)
        language="$2"
        shift
    ;;
    -k)
        timeout="timeout $2"
        shift
    ;;
    -a)
        author="$2"
        shift
    ;;
    -d)
        date=""
    ;;
    -t)
        title="$2"
        shift
    ;;
    -f)
        fixmelist="yes"
    ;;
    -g)
        glossary="yes"
    ;;
    -o)
        file="$2"
        shift
    ;;
    --save|-s)
        save="yes"
    ;;
    -c)
        if [ ! -f ".nogconfig" ]; then
            echo "Generating configuration file ./.nogconfig"
            echo "$defaultconfigfile" > .nogconfig
            exit 0
        else
            echo "Configurationi file ./.nogconfig already exists in this directory"
            exit 3
        fi
    ;;
    --only-tex)
        only_tex="yes"
    ;;
    --also-tex)
        also_tex="yes"
    ;;
    -*)
        echo Unknown option $1
        exit 1
    ;;
    *)
        addfile $1
    ;;
    esac
    shift
done

##
# CONSTRUCT THE APPENDICES IF SPECIFIED IN THE OPTIONS
##
if [ "${fixmelist,,}" == "yes" ]; then
    fixmelist="
\\section{$fixmelist_name}
\\noindent\\fixmelist
"
        preappendices="
\\newpage
"
else
    fixmelist=""
fi

if [ "${glossary,,}" == "yes" ]; then
        glossary="
\\section{$glossary_name}
\\noindent\\myglossary
"
        preappendices="
\\newpage
"
else
    glossary=""
fi

##
# CHECK IF ANY INPUT FILE HAS BEEN SPECIFIED, ONE WAY OR ANOTHER. IF NOT,
# EXIT WITH AN ERROR
##
if [ -z "$files" ]
then
    echo Provide input file
    exit 1
fi

##
# CREATE TEMPORAL FILES
##
nogtempdir=$(mktemp -d)
nogtemptex="$nogtempdir/nogtemp.tex"



##
# FIRST PART OF THE SKELETON
##
cat << _END_ > "$nogtemptex"
\documentclass{article}

\usepackage[utf8]{inputenc} % UNICODE INPUT
\usepackage[$language]{babel} % LANGUAGE
\usepackage[left=3cm,
            right=2cm,
            top=1.5cm,
            bottom=1.5cm,
            marginparwidth=2.75cm,
            marginparsep=0.25cm]
            {geometry}  % FORMATTING
\usepackage{minitoc}    % TABLES OF CONTENTS FOR SECTIONS
\usepackage{pifont}     % FOR THE HAND GLYPH
\usepackage{listings}   % FOR CODE SYNTAX HIGHLIGHT
\usepackage{xcolor}     % MORE COLOR
\usepackage{perpage}    % FOR FOOTNOTES NUMBERING
\usepackage{tikz}       % GRAPHS AND DRAWINGS
\usepackage{forest}     % FOR SCHEMES
\usepackage[hidelinks]{hyperref} % FOR LINKS
\usepackage{bookmark}   % FOR LINKS IN TOC
\usepackage{appendix}   % FOR THE GLOSSARY
\usepackage{enumitem}   % TO CHANGE ITEMS IN ITEMIZES
\usepackage{multicol}   % TO SEPARATE TEXT IN COLUMNS

% SOME COLORS DEFINED

\definecolor{gray}{rgb}{0.5,0.5,0.5}

\definecolor{fixme}{rgb}{1,0,0}
\definecolor{string}{rgb}{0,0.6,0}
\definecolor{comment}{rgb}{0.5,0.5,0.5}
\definecolor{number}{rgb}{0.25,0.25,0.25}
\definecolor{background}{rgb}{0.95,0.95,0.95}
\definecolor{framecolor}{rgb}{0.5,0.5,0.5}
\definecolor{keyword}{rgb}{0,0,0.6}

% STYLE FOR CODE

\lstset{
    backgroundcolor=\color{background},
    frame=l,
    rulecolor=\color{framecolor},
    numbers=left,
    numberstyle=\scriptsize\color{number},
    numbersep=6pt,
    aboveskip=3mm,
    belowskip=3mm,
    basicstyle={\small\ttfamily},
    showstringspaces=false,
    keywordstyle=\color{keyword},
    commentstyle=\color{comment},
    stringstyle=\color{string},
    breaklines=true,
    breakatwhitespace=true,
    tabsize=3
    }

% STYLE FOR SCHEMES

\usetikzlibrary{decorations.pathreplacing}
\forestset{
    forest scheme/.style={
        for tree={
            grow'=0,
            anchor=west,
            align=left,
            if n=1{%
            edge path={
                \noexpand\path [\forestoption{edge}] (!ul.south west) -- (!u1.north west)\forestoption{edge label};
            }
            }{no edge},
            edge={decorate, decoration={brace}},
        },
    }
}

% STYLE FOR GRAPHS

\usetikzlibrary{arrows.meta}

\tikzset{simple/.style={black, draw=black, circle, minimum size=0.5cm}}
\tikzset{emph/.style={black,draw=red, circle,minimum size=0.5cm}}
\tikzset{more emph/.style={red,draw=red, circle,minimum size=0.5cm}}

\tikzset{final/.style={black,draw=black, circle, double, double distance=1.5pt, minimum size=0.5cm}}
\tikzset{final emph/.style={black,draw=red, circle, double, double distance=1.5pt, minimum size=0.5cm}}
\tikzset{final more emph/.style={red,draw=red, circle, double, double distance=1.5pt, minimum size=0.5cm}}

\tikzset{dir/.style={-{Latex[length=3mm]}}}
\tikzset{diremph/.style={red,-{Latex[length=3mm]}}}

\tikzset{dirop/.style={{Latex[length=3mm]}-}}
\tikzset{diropemph/.style={red,{Latex[length=3mm]}-}}

% MINOR OPTIONS

\MakePerPage{footnote}
\reversemarginpar

% TOC FOR SECTIONS SETUP 

\setcounter{tocdepth}{2}

\dosecttoc
\setcounter{secttocdepth}{3}
\mtcsettitle{secttoc}{}

% COMMANDS FOR UNIFYING STYLE

\setlength{\parindent}{0pt} % NO MORE INDENTATION
\newcommand{\unit}[1]{\newpage\section{#1}\secttoc}
\newcommand{\unitsection}[1]{\subsection{#1}}
\newcommand{\unitsubsection}[1]{\subsubsection{#1}}

\newcommand{\keyword}[1]{\marginpar{
            \center
            \scriptsize
            \uppercase{#1}\\\\
            \Large\ding{43}
        }
        \glossary{name={#1}}
        \textbf{#1}}
\newcommand{\fixme}{
            \marginpar{
                    \center
                    \scriptsize
                    \color{fixme}{
                        \textbf{FIX ME}\\\\
                    }
                \Large\ding{43}
            }
            {\color{fixme}(!)}
        }

\newcommand{\codelan}[1]{ lstset{language=#1} }
\newcommand{\codeword}[1]{\colorbox{background}{\small\texttt{#1}}}

% PARAMETERS SET BY NOG (BY DEFAULT OR WITH OPTIONS)

\title{$title}
\author{$author}
$date

%%  CODE GENERATED BY THE PREPROCESSOR. IT MAY OVERRIDE THE OPTIONS ABOVE

_END_

##
# STEP ONE: PREPROCESSOR
##
nogpre $files >> "$nogtemptex"

##
# SECOND PART OF THE SKELETON
##
cat << _END_ >> "$nogtemptex"

%% END OF PREPROCESSOR CODE

\begin{document}
    \maketitle
    \myindex
_END_

##
# STEP TWO: LEXER
##
noglex $files >> "$nogtemptex"

##
# THIRD PART OF THE SKELETON
##
cat << _END_ >> "$nogtemptex"

$preappendices
\begin{appendices}
$glossary
$fixmelist
\end{appendices}

\end{document}
_END_

##
# STEPS THREE AND FOUR: PDFLATEX
##
if [ "${only_tex,,}" == "yes" ]; then
    cp "$nogtemptex" "$file.tex"
    echo "$file.tex succesfully generated"
else
    if [ "${also_tex,,}" == "yes" ]; then
        cp "$nogtemptex" "$file.tex"
        echo "$file.tex succesfully generated"
    fi
    $timeout pdflatex -draftmode -output-directory "$nogtempdir" "$nogtemptex" > /dev/null 2>&1 &&
    pdflatex -output-directory "$nogtempdir" "$nogtemptex" > /dev/null 2>&1 &&
    mv "$nogtempdir/"*"pdf" "./$file.pdf" > /dev/null &&
    echo "$file.pdf succesfully generated" ||
    echo "Latex Errors:" &&
    grep '^!' "$nogtempdir/nogtemp.log" &&
    exit 1
fi
##
# SAVE THE TEMPORAL FILES IF IT WAS REQUESTED
##
if [ "${save,,}" == "yes"  ]
then
    echo "Saving temporal files"
    rm -f -r nogtmp
    mv "$nogtempdir" nogtmp
else
    # not actually necessary, but meh
    rm -r "$nogtempdir"
fi
echo "Done"
