Use the software in this directory to start a new paper.

Required Directories
--------------------

The following directories should be downloaded onto your computer, either individually or as part of the entire "Utilities" repository:
- PaperStarter
- LaTeX

Environment Variables
---------------------

Environment variables for Linux/Unix based operating systems are typically set in a script in your home directory, such as a .bashrc file.  In order to use this software, you must have the following environment variables defined:

- PAPERSTARTER : should be set to the path of the PaperStarter directory mentioned above
- DPRFECLATEX  : should be set to the path of the LaTeX directory mentioned above

For example, this is how they are set in Daniel's .bashrc file on his Macbook:

PAPERSTARTER=/Users/danielrobinson/git/Utilities/PaperStarter
DPRFECLATEX=/Users/danielrobinson/git/Utilities/LaTeX
PATH="/Users/danielrobinson/Dropbox/daniel/git/Utilities/PaperStarter/bin:${PATH}"
export PAPERSTARTER DPRFECLATEX PATH

In this example, notice that Daniel has appended his "PaperStarter/bin" directory to his PATH environment variable.  This allows him to run the executable file for the PaperStarter software in his terminal from within any directory on his computer.  We suggest that you do the same.

Usage
-----

If your environment variables are set properly, then you should be able to run the command

```
paper_starter
```

from your terminal to start a new paper.  Be sure to run the command from the directory in which you want to place the new paper.  You know it is working correctly if you are prompted with a series of questions to answer.

Good luck!