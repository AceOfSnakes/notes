# Makefile for the PuTTY icon suite.

ICONS = putty puttycfg puttygen pscp pageant pterm ptermcfg puttyins
SIZES = 16 32 48 64 128 256

MODE = # override to -it on command line for opaque testing

PAMS = $(foreach I,$(ICONS),$(foreach S,$(SIZES),$(I)-$(S).pam))
MONOPAMS = $(foreach I,$(ICONS),$(foreach S,$(SIZES),$(I)-$(S)-mono.pam))
TRUEPAMS = $(foreach I,$(ICONS),$(foreach S,$(SIZES),$(I)-$(S)-true.pam))

PNGS = $(patsubst %.pam,%.png,$(PAMS))
MONOPNGS = $(patsubst %.pam,%.png,$(MONOPAMS))
TRUEPNGS = $(patsubst %.pam,%.png,$(TRUEPAMS))

SVGS = $(patsubst %,%.svg,$(ICONS))

ICOS = putty.ico puttygen.ico pscp.ico pageant.ico pageants.ico puttycfg.ico \
       puttyins.ico pterm.ico ptermcfg.ico
ICNS = PuTTY.icns Pterm.icns
CICONS = xpmputty.c xpmpucfg.c xpmpterm.c xpmptcfg.c

base: icos cicons

all: pngs monopngs base icns svgs # truepngs currently disabled by default

pngs: $(PNGS)
monopngs: $(MONOPNGS)
truepngs: $(TRUEPNGS)
svgs: $(SVGS)

icos: $(ICOS)
icns: $(ICNS)
cicons: $(CICONS)

install: icos cicons
	cp $(ICOS) ../windows
	cp $(CICONS) ../unix

$(PAMS): %.pam: mkicon.py
	./mkicon.py $(MODE) $(join $(subst -, ,$(basename $@)),_icon) $@

$(PNGS) $(MONOPNGS) $(TRUEPNGS): %.png: %.pam
	convert $< $@

$(MONOPAMS): %.pam: mkicon.py
	./mkicon.py -2 $(MODE) $(join $(subst -, ,$(subst -mono,,$(basename $@))),_icon) $@

$(TRUEPAMS): %.pam: mkicon.py
	./mkicon.py -T $(MODE) $(join $(subst -, ,$(subst -true,,$(basename $@))),_icon) $@

$(SVGS): %.svg: mksvg.py
	./mksvg.py $(patsubst %.svg,%_icon,$@) -o $@

putty.ico: $(PNGS) $(MONOPNGS)
	./icon.pl -4  $(filter putty-%.png, $^)  -1 $(filter putty-%-mono.png, $^)> $@

puttycfg.ico: $(PNGS) $(MONOPNGS)
	./icon.pl -4 $(filter puttycfg-%.png, $^) -1 $(filter puttycfg-1%-mono.png, $^) > $@

puttygen.ico: $(PNGS) ${MONOPNGS}
	./icon.pl -4 $(filter puttygen-%.png, $^) -1 $(filter puttygen-%-mono.png, $^) > $@

pageant.ico: $(PNGS) $(MONOPNGS)
	./icon.pl -4 $(filter pageant-%.png, $^) -1 $(filter pageant-%-mono.png, $^) > $@

pageants.ico: $(PNGS) $(MONOPNGS)
	./icon.pl -4 $(filter pageant-%.png, $^) -1 $(filter pageant-%-mono.png, $^) > $@

pscp.ico: $(PNGS) $(MONOPNGS)
	./icon.pl -4 $(filter pscp-%.png, $^) -1 $(filter pscp-%-mono.png, $^) > $@

pterm.ico: $(PNGS) $(MONOPNGS)
	./icon.pl -4 $(filter pterm-%.png, $^) -1 $(filter pterm-%-mono.png, $^) > $@

ptermcfg.ico: $(PNGS) $(MONOPNGS)
	./icon.pl -4 $(filter ptermcfg-%.png, $^) -1 $(filter ptermcfg-%-mono.png, $^) > $@


# Because the installer icon makes heavy use of brown when drawing
# the cardboard box, it's worth having 8-bit versions of it in
# addition to the 4- and 1-bit ones.
puttyins.ico: puttyins-16.png puttyins-32.png puttyins-48.png \
              puttyins-16-mono.png puttyins-32-mono.png \
              puttyins-48-mono.png \
              puttyins-16-true.png puttyins-32-true.png \
              puttyins-48-true.png
	./icon.pl -8 $(filter %-true.png, $^) \
                  -4 $(filter-out %-true.png, $(filter-out %-mono.png, $^)) \
                  -1 $(filter %-mono.png, $^) > $@

# Icon for the website. (This isn't linked into "make all".)
website.ico: putty-16.png
	./icon.pl -4 $^ >$@

xpmputty.c: ${PNGS}
	./cicon.pl main_icon $(filter putty-%.png ,$^) > $@

xpmpucfg.c: ${PNGS}
	./cicon.pl cfg_icon $(filter puttycfg-%.png ,$^) > $@

xpmpterm.c: ${PNGS}
	./cicon.pl cfg_icon $(filter pterm-%.png ,$^) > $@

xpmptcfg.c: ${PNGS}
	./cicon.pl cfg_icon $(filter ptermcfg-%.png ,$^) > $@

PuTTY.icns: putty-16-mono.pam putty-16.pam \
	    putty-32-mono.pam putty-32.pam \
	    putty-48-mono.pam putty-48.pam \
	    putty-128.pam
	./macicon.py mono:putty-16-mono.pam colour:putty-16.pam \
	             mono:putty-32-mono.pam colour:putty-32.pam \
	             mono:putty-48-mono.pam colour:putty-48.pam \
	                                    colour:putty-128.pam \
		output:$@

Pterm.icns: pterm-16-mono.pam pterm-16.pam \
	    pterm-32-mono.pam pterm-32.pam \
	    pterm-48-mono.pam pterm-48.pam \
	    pterm-128.pam
	./macicon.py mono:pterm-16-mono.pam colour:pterm-16.pam \
	             mono:pterm-32-mono.pam colour:pterm-32.pam \
	             mono:pterm-48-mono.pam colour:pterm-48.pam \
	                                    colour:pterm-128.pam \
		output:$@

clean:
	rm -f *.pam *.png *.ico *.icns *.c *.svg
