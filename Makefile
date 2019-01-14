CMD = blink bsearch duplicate-packets em encdir field forever G		\
	gitnext gitundo goodpasswd histogram mtrr mirrorpdf neno off	\
	pdfman plotpipe puniq ramusage rand rclean rina rn rrm		\
	shython sound-reload stdout swapout T timestamp tracefile	\
	transpose upsidedown vid w4it-for-port-open wifi-reload wssh	\
	ytv yyyymmdd

all: blink/blink.1 bsearch/bsearch.1 encdir/encdir.1 G/G.1		\
	gitnext/gitnext.1 gitundo/gitundo.1 goodpasswd/goodpasswd.1	\
	histogram/histogram.1 mirrorpdf/mirrorpdf.1 neno/neno.1		\
	off/off.1 pdfman/pdfman.1 plotpipe/plotpipe.1 puniq/puniq.1	\
	rand/rand.1 rina/rina.1 rn/rn.1 rrm/rrm.1 shython/shython.1	\
	sound-reload/sound-reload.1 stdout/stdout.1			\
	timestamp/timestamp.1 tracefile/tracefile.1			\
	transpose/transpose.1 T/T.1 upsidedown/upsidedown.1 vid/vid.1	\
	wifi-reload/wifi-reload.1 wssh/wssh.1 ytv/ytv.1			\
	yyyymmdd/yyyymmdd.1

%.1: %
	pod2man $< > $@

install:
	mkdir -p /usr/local/bin
	parallel eval ln -sf `pwd`/*/{} /usr/local/bin/{} ::: $(CMD)
	mkdir -p /usr/local/share/man/man1
	parallel ln -sf `pwd`/{} /usr/local/share/man/man1/{/} ::: */*.1
