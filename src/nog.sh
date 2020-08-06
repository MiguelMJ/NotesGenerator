#!/bin/bash
version="nog 1.1"
usage='Usage: nog [OPTIONS] [FILES]
Reads in order a list of files and processes them in several steps to generate a pdf file via *pdflatex*.

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
    Name of the output file without the pdf extension.
-s, --save
    Save temporal files (including the .tex).
-g  
    Add an appendix with the glossary.
-f  
    Add an appendix with the list of fixme.
-k timeout
    Kill pdflatex after timeout seconds, if it doesn'"'"'t compile.  By 
    default it is 5 (seconds).
-l language
    Sets the language for the LaTex package babel.
'

# PRINT BASIC USAGE
if [ $# -eq 0 ]; then
    echo -e "$version\n$usage"
    exit 0
fi

# DEFAULT VALUES FOR PARAMETERS

title="Notes"
author=""
date="\\date{}"
file="$title"
preappendices=""
glossary=""
fixmelist=""
timeout="timeout 5"
language="spanish"

# TEMPORAL FILES

nogtempdir=$(mktemp -d)
nogtemptex="$nogtempdir/nogtemp.tex"

# OPTION PARSING

while [ "${1:0:1}" == "-" ]
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
        fixmelist="
\\section{FIXME}
\\noindent\\fixmelist
"
        preappendices="
\\newpage
"
    ;;
    -g)
        glossary="
\\section{Conceptos clave}
\\noindent\\myglossary
"
        preappendices="
\\newpage
"
    ;;
    -o)
        file="$2"
        shift
    ;;
    --save|-s)
        save="true"
    ;;
    *)
        echo Unknown option $1
        exit 1
    ;;
    esac
    shift
done

if [ $# == 0 ]
then
    echo Provide input file
    exit 1
fi
#
# FIRST PART OF THE SKELETON
#
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
% \usepackage{cancel}     % ENABLING \cancel COMMANDS IN MATHMODE
\usepackage{tikz}       % GRAPHS AND DRAWINGS
\usepackage{forest}     % FOR SCHEMES
\usepackage[hidelinks]{hyperref} % FOR LINKS
\usepackage{bookmark}   % FOR LINKS IN TOC
\usepackage{appendix}   % FOR THE GLOSSARY
\usepackage{enumitem}   % TO CHANGE ITEMS IN ITEMIZES
\usepackage{multicol}   % TO SEPARATE TEXT IN COLUMNS
% \usepackage{stmaryrd}   % TO USE SYNTACTIC BRACKETS
% \usepackage{amsmath}    % EMBEDDED TEXT IN MATH MODE


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

nogpre $* >> "$nogtemptex"

cat << _END_ >> "$nogtemptex"

%% END OF PREPROCESSOR CODE

\begin{document}
    \maketitle
    \myindex
_END_

noglex $* >> "$nogtemptex"

cat << _END_ >> "$nogtemptex"

$preappendices
\begin{appendices}
$glossary
$fixmelist
\end{appendices}

\end{document}
_END_

$timeout pdflatex -draftmode -output-directory "$nogtempdir" "$nogtemptex" > /dev/null 2>&1 &&
pdflatex -output-directory "$nogtempdir" "$nogtemptex" > /dev/null 2>&1 &&
mv "$nogtempdir/"*"pdf" "./$file.pdf" > /dev/null &&
echo "$file.pdf succesfully generated" ||
echo "Latex Errors:" &&
grep '^!' "$nogtempdir/nogtemp.log" &&
exit 1

if [ ! -z "$save"  ]
then
    echo "Saving temporal files"
    mv "$nogtempdir" nogtmp
else
    # not actually necessary, but meh
    echo "Deleting temporal files"
    rm -r "$nogtempdir"
fi
echo "Done"
