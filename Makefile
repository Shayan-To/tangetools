CMD = blink bsearch em G gitnext goodpasswd histogram neno pdfman \
puniq ramusage rand rclean rn rrm stdout T timestamp tracefile	  \
upsidedown wssh

all: blink/blink.1 bsearch/bsearch.1 G/G.1 gitnext/gitnext.1 goodpasswd/goodpasswd.1 histogram/histogram.1 neno/neno.1 pdfman/pdfman.1 puniq/puniq.1 rand/rand.1 rn/rn.1 rrm/rrm.1 stdout/stdout.1 timestamp/timestamp.1 tracefile/tracefile.1 T/T.1 upsidedown/upsidedown.1 wssh/wssh.1

%.1: %
	pod2man $< > $@

install:
	mkdir -p /usr/local/bin
	parallel eval ln -sf `pwd`/*/{} /usr/local/bin/{} ::: $(CMD)
	mkdir -p /usr/local/share/man/man1
	parallel ln -sf `pwd`/{} /usr/local/share/man/man1/{/} ::: */*.1
