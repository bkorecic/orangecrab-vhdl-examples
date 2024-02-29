PROJ = neorv32_test_setup_approm

# `r0.1` or `r0.2` or `r0.2.1`
VERSION := r0.2.1
# `25F` or `85F`
DENSITY := 85F

NEORV32_CORE_DIR = neorv32/rtl/core

# We need the files to be analyzed in a specific order
NEORV32_FILES = $(NEORV32_CORE_DIR)/neorv32_package.vhd \
	$(NEORV32_CORE_DIR)/neorv32_application_image.vhd \
	$(NEORV32_CORE_DIR)/neorv32_bootloader_image.vhd \
	$(NEORV32_CORE_DIR)/neorv32_dmem.entity.vhd \
	$(NEORV32_CORE_DIR)/neorv32_imem.entity.vhd \
	$(NEORV32_CORE_DIR)/mem/neorv32_dmem.default.vhd \
	$(NEORV32_CORE_DIR)/mem/neorv32_imem.default.vhd \
	$(NEORV32_CORE_DIR)/neorv32_boot_rom.vhd \
	$(NEORV32_CORE_DIR)/neorv32_cfs.vhd \
	$(NEORV32_CORE_DIR)/neorv32_clockgate.vhd \
	$(NEORV32_CORE_DIR)/neorv32_fifo.vhd \
	$(NEORV32_CORE_DIR)/neorv32_cpu_decompressor.vhd \
	$(NEORV32_CORE_DIR)/neorv32_cpu_control.vhd \
	$(NEORV32_CORE_DIR)/neorv32_cpu_cp_bitmanip.vhd \
	$(NEORV32_CORE_DIR)/neorv32_cpu_cp_cfu.vhd \
	$(NEORV32_CORE_DIR)/neorv32_cpu_cp_cond.vhd \
	$(NEORV32_CORE_DIR)/neorv32_cpu_cp_fpu.vhd \
	$(NEORV32_CORE_DIR)/neorv32_cpu_cp_muldiv.vhd \
	$(NEORV32_CORE_DIR)/neorv32_cpu_cp_shifter.vhd \
	$(NEORV32_CORE_DIR)/neorv32_cpu_lsu.vhd \
	$(NEORV32_CORE_DIR)/neorv32_cpu_pmp.vhd \
	$(NEORV32_CORE_DIR)/neorv32_cpu_regfile.vhd \
	$(NEORV32_CORE_DIR)/neorv32_cpu_alu.vhd \
	$(NEORV32_CORE_DIR)/neorv32_cpu.vhd \
	$(NEORV32_CORE_DIR)/neorv32_crc.vhd \
	$(NEORV32_CORE_DIR)/neorv32_dcache.vhd \
	$(NEORV32_CORE_DIR)/neorv32_debug_dm.vhd \
	$(NEORV32_CORE_DIR)/neorv32_debug_dtm.vhd \
	$(NEORV32_CORE_DIR)/neorv32_dma.vhd \
	$(NEORV32_CORE_DIR)/neorv32_gpio.vhd \
	$(NEORV32_CORE_DIR)/neorv32_gptmr.vhd \
	$(NEORV32_CORE_DIR)/neorv32_icache.vhd \
	$(NEORV32_CORE_DIR)/neorv32_intercon.vhd \
	$(NEORV32_CORE_DIR)/neorv32_mtime.vhd \
	$(NEORV32_CORE_DIR)/neorv32_neoled.vhd \
	$(NEORV32_CORE_DIR)/neorv32_onewire.vhd \
	$(NEORV32_CORE_DIR)/neorv32_pwm.vhd \
	$(NEORV32_CORE_DIR)/neorv32_sdi.vhd \
	$(NEORV32_CORE_DIR)/neorv32_slink.vhd \
	$(NEORV32_CORE_DIR)/neorv32_spi.vhd \
	$(NEORV32_CORE_DIR)/neorv32_sysinfo.vhd \
	$(NEORV32_CORE_DIR)/neorv32_trng.vhd \
	$(NEORV32_CORE_DIR)/neorv32_twi.vhd \
	$(NEORV32_CORE_DIR)/neorv32_uart.vhd \
	$(NEORV32_CORE_DIR)/neorv32_wdt.vhd \
	$(NEORV32_CORE_DIR)/neorv32_wishbone.vhd \
	$(NEORV32_CORE_DIR)/neorv32_xip.vhd \
	$(NEORV32_CORE_DIR)/neorv32_xirq.vhd \
	$(NEORV32_CORE_DIR)/neorv32_top.vhd


PROJ_FILES = $(PROJ).vhd $(NEORV32_FILES)

ifneq (,$(findstring 85,$(DENSITY)))
	NEXTPNR_DENSITY:=--85k
else
	NEXTPNR_DENSITY:=--25k
endif

analyze:
	ghdl -a --work=neorv32 $(NEORV32_FILES)
	ghdl -a $(PROJ).vhd

list-files:
	@echo $(PROJ_FILES)

dfu: $(PROJ).dfu
	dfu-util --alt 0 -D $<

all: $(PROJ).dfu

%.vhd: ;

%.cf: %.vhd
	ghdl -a --work=neorv32 $(NEORV32_FILES)
	ghdl -a $(PROJ).vhd
	ghdl clean --work=neorv32
	ghdl clean

# Build the yosys script.
# This recipe depends on the actual VHDL files (defined in $(PROJ_FILES))
# Also, this recipe will generate the whole script as an intermediate file.
# The script will call ghdl for each file listed in $(PROJ_FILES),
%.ys: $(PROJ_FILES)
	$(file >$@)
	$(file >>$@,ghdl -a --work=neorv32 $(NEORV32_FILES))
	$(file >>$@,ghdl -a $(TOP_MODULE).vhd)
	$(file >>$@,ghdl -e $(TOP_MODULE))

%.json: %.cf
	yosys -m ghdl -p "ghdl $(PROJ); synth_ecp5 -json $@"

%_out.config: %.json
	nextpnr-ecp5 --json $< --textcfg $@ $(NEXTPNR_DENSITY) --package CSFBGA285 --lpf ../orangecrab_${VERSION}.pcf

%.bit: %_out.config
	ecppack --compress --freq 38.8 --input $< --bit $@

%.dfu : %.bit
	cp -a $< $@
	dfu-suffix -v 1209 -p 5af0 -a $@

clean:
	rm -f ${PROJ}.bit ${PROJ}_out.config ${PROJ}.json ${PROJ}.dfu
	ghdl remove
	ghdl remove --work=neorv32
