all: paper techreport

paper: name_paper.pdf
name_paper.pdf: name_paper.tex abstract.tex body.tex references.bib
	-pdflatex name_paper.tex
	-bibtex name_paper
	-bibtex name_paper
	-pdflatex name_paper.tex
	-pdflatex name_paper.tex
	-pdflatex name_paper.tex
	-rm -f *.aux *.blg *.log *.out *.gz *.thm

techreport: name_techreport.pdf
name_techreport.pdf: name_techreport.tex abstract.tex body.tex references.bib
	-pdflatex name_techreport.tex
	-bibtex name_techreport
	-bibtex name_techreport
	-pdflatex name_techreport.tex
	-pdflatex name_techreport.tex
	-pdflatex name_techreport.tex
	-rm -f *.aux *.blg *.log *.out *.gz *.thm

clean:
	-rm -f *.aux *.blg *.log *.out *.gz *.thm *.pdf *.bbl
