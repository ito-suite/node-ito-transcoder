#!/bin/bash

# https://superuser.com/questions/601198/how-can-i-automatically-convert-all-source-code-files-in-a-folder-recursively

# also need texlive-humanities for line numbering

# $1 = absolute path to file(s)

    base=$(basename $1)
    base="${base%.*}"
    dir=$(dirname $1)
    texdir="${dir}/${base}/tex"
    mkdir "${texdir}"

    tex_file="/tmp/${2}.tex" ## Change this to whatever you want
    touch tex_file
#    tex_file="~/Documents/render.tex" ## Change this to whatever you want

cat<<EOF >$tex_file   ## Print the tex file header
\documentclass{article}


\usepackage{listings}
\usepackage{lineno}
\usepackage[usenames,dvipsnames]{color}  %% Allow color names
\lstdefinelanguage{JavaScript}{
  keywords={break, case, catch, continue, debugger, default, delete, do, else, finally, for, function, if, in, instanceof, new, return, switch, this, throw, try, typeof, var, void, while, with},
  morecomment=[l]{//},
  morecomment=[s]{/*}{*/},
  morestring=[b]',
  morestring=[b]",
  sensitive=true
}
\lstdefinestyle{customasm}{
  belowcaptionskip=1\baselineskip,
  xleftmargin=\parindent,
  language=Javascript,   %% Change this to whatever you write in
  breaklines=true, %% Wrap long lines
  basicstyle=\footnotesize\ttfamily,
  commentstyle=\itshape\color{Gray},
  stringstyle=\color{Black},
  keywordstyle=\bfseries\color{OliveGreen},
  identifierstyle=\color{blue},
  xleftmargin=0em,
}        
\usepackage[colorlinks=true,linkcolor=blue]{hyperref} 
\usepackage[top=1in, bottom=1in, left=1in, right=1in]{geometry}

\begin{document}
\title{ARCHIVITEKT SOURCE : $2 }
\author{antonym & denjell}
\maketitle
\tableofcontents

EOF

find $1 -type f ! -regex ".*/\..*" ! -name "*.xcf" ! -name "*.png" ! -name "*.jpg" \
  ! -name "*.ico" ! -name "*.gif" ! -name "*.eot" ! -name "*.svg" ! -name "*.ttf" \
  ! -name "*.min.*" ! -name "*-min.*" ! -name "*.html" ! -name "*.json" \
  ! -name "*.woff" ! -name "*.otf" ! -name "*~" ! -name ".pdf" | 
  sed 's/^\..//' |                 ## Change ./foo/bar.src to foo/bar.src

while read  i; do                ## Loop through each file
    echo "\newpage" >> $tex_file   ## start each section on a new page

    echo "\section{$i}" >> $tex_file  ## Create a section for each file

   ## This command will include the file in the PDF
    echo "\resetlinenumber" >> $tex_file
    echo "\begin{linenumbers}" >> $tex_file
    echo "\lstinputlisting[style=customasm]{$i}" >> $tex_file
    echo "\end{linenumbers}" >> $tex_file

done &&
echo "\end{document}" >> $tex_file &

# we need to run this twice to make sure the TOC is created
pdflatex -output-directory="/home/egal/Documents" -interaction=nonstopmode $tex_file &&
pdflatex -output-directory="/home/egal/Documents" -interaction=nonstopmode $tex_file

# check this out: /home/egal/jobs/fachez/fachez-frontend/node_modules/express/node_modules/connect/node_modules/multiparty/test/fixture
echo $texdir