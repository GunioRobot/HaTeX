TEX = platex

hoge.pdf: hoge.tex
	${TEX} hoge.tex
	dvipdf hoge.dvi

hoge.tex: hatena.txt
	./hatextest.pl hatena.txt>hoge.tex

.PHONY: clean

clean:
	rm *.aux *.log *.pdf *.dvi

