Use this project to start a new research paper.  

*Directories Needed*  

The following directories should be downloaded from the "Utilities" repository:
- PaperStarter  
- LaTeX  

*Environment Variables Needed*  

Environment variables for linux/unix based machines are typically set in a .bashrc file.
In order to use this package, you must have the following environment variables defined:  
   - DPRFECLATEX  : this should be set to the path of the LaTeX directory described above.
   - PAPERSTARTER : this should be set to the path of the PaperStarter directory described above.

For example, here is how they are set on Daniel Robinson's mac inside of his .bashrc file:

   DPRFECLATEX=/Users/danielrobinson/git/Utilities/LaTeX  
   PAPERSTARTER=/Users/danielrobinson/git/Utilities/PaperStarter  
   PATH="/Users/danielrobinson/Dropbox/daniel/git/Utilities/PaperStarter/bin:${PATH}"  
   export PAPERSTARTER DPRFECLATEX PATH  

In this example, notice that Daniel has appended the "bin" directory inside of "PaperStarter"
to his PATH environment variable.  This allows him to run the executable file for this 
project in his terminal from any directory on his machine.  We suggest you do the same.

*Use*  
If your environment variables are set up properly, you should be able to run the command  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; paper_starter  
in your terminal to start a new paper. If it starts asking you questions in the terminal,
then things should be workign properly.  Good luck!
