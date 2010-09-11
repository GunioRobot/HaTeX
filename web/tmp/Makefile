TARGET=fuga
TEX=platex
DVI2PDF=dvipdfm

${TARGET}.pdf: ${TARGET}.dvi
${TARGET}.dvi: ${TARGET}.tex

.SUFFIXES: .pdf .dvi .tex

.tex.dvi:
	${TEX} $<

.dvi.pdf:
	${DVI2PDF} $<
	
.PHONY: clean

clean:
	yes|rm ${TARGET}.log ${TARGET}.dvi ${TARGET}.aux ${TARGET}.tex ${TARGET}.pdf

