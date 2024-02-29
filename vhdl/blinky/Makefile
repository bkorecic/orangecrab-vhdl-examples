PROJ = blinky

# `r0.1` or `r0.2` or `r0.2.1`
VERSION:=r0.2.1
# `25F` or `85F`
DENSITY = 85F

ifneq (,$(findstring 85,$(DENSITY)))
	NEXTPNR_DENSITY:=--85k
else
	NEXTPNR_DENSITY:=--25k
endif

dfu: $(PROJ).dfu
	dfu-util --alt 0 -D $<

all: $(PROJ).dfu

%.json: %.vhd
	yosys -m ghdl -p "ghdl $< -e $(PROJ); synth_ecp5 -json $@"

%_out.config: %.json
	nextpnr-ecp5 --json $< --textcfg $@ $(NEXTPNR_DENSITY) --package CSFBGA285 --lpf ../orangecrab_${VERSION}.pcf

%.bit: %_out.config
	ecppack --compress --freq 38.8 --input $< --bit $@

%.dfu : %.bit
	cp -a $< $@
	dfu-suffix -v 1209 -p 5af0 -a $@

clean:
	rm -f ${PROJ}.bit ${PROJ}_out.config ${PROJ}.json ${PROJ}.dfu
