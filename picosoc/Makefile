
CROSS=riscv64-unknown-elf-
CFLAGS=

all: icesimg

# ---- iCE40 HX8K Breakout Board ----

hx8ksim: hx8kdemo_tb.vvp hx8kdemo_fw.hex
	vvp -N $< +firmware=hx8kdemo_fw.hex

hx8ksynsim: hx8kdemo_syn_tb.vvp hx8kdemo_fw.hex
	vvp -N $< +firmware=hx8kdemo_fw.hex

hx8kdemo.json: hx8kdemo.v spimemio.v simpleuart.v picosoc.v ../picorv32.v
	yosys -ql hx8kdemo.log -p 'synth_ice40 -top hx8kdemo -json hx8kdemo.json' $^

hx8kdemo_tb.vvp: hx8kdemo_tb.v hx8kdemo.v spimemio.v simpleuart.v picosoc.v ../picorv32.v spiflash.v
	iverilog -s testbench -o $@ $^ `yosys-config --datdir/ice40/cells_sim.v`

hx8kdemo_syn_tb.vvp: hx8kdemo_tb.v hx8kdemo_syn.v spiflash.v
	iverilog -s testbench -o $@ $^ `yosys-config --datdir/ice40/cells_sim.v`

hx8kdemo_syn.v: hx8kdemo.json
	yosys -p 'read_json $<; write_verilog $@'

hx8kdemo.asc: hx8kdemo.pcf hx8kdemo.json
	nextpnr-ice40 --hx8k --package ct256 --asc hx8kdemo.asc --json hx8kdemo.json --pcf hx8kdemo.pcf

hx8kdemo.bin: hx8kdemo.asc
	icetime -d hx8k -c 12 -mtr hx8kdemo.rpt hx8kdemo.asc
	icepack hx8kdemo.asc hx8kdemo.bin

hx8kprog: hx8kdemo.bin hx8kdemo_fw.bin
	iceprog hx8kdemo.bin
	iceprog -o 1M hx8kdemo_fw.bin

hx8kprog_fw: hx8kdemo_fw.bin
	iceprog -o 1M hx8kdemo_fw.bin

hx8kdemo_sections.lds: sections.lds
	$(CROSS)cpp -P -DHX8KDEMO -o $@ $^

hx8kdemo_fw.elf: hx8kdemo_sections.lds start.s firmware.c
	$(CROSS)gcc $(CFLAGS) -DHX8KDEMO -mabi=ilp32 -march=rv32imc -Wl,--build-id=none,-Bstatic,-T,hx8kdemo_sections.lds,--strip-debug -ffreestanding -nostdlib -o hx8kdemo_fw.elf start.s firmware.c

hx8kdemo_fw.hex: hx8kdemo_fw.elf
	$(CROSS)objcopy -O verilog hx8kdemo_fw.elf hx8kdemo_fw.hex

hx8kdemo_fw.bin: hx8kdemo_fw.elf
	$(CROSS)objcopy -O binary hx8kdemo_fw.elf hx8kdemo_fw.bin

# ---- iCE40 IceBreaker Board ----

icebsim: icebreaker_tb.vvp icebreaker_fw.hex
	vvp -N $< +firmware=icebreaker_fw.hex

icebsynsim: icebreaker_syn_tb.vvp icebreaker_fw.hex
	vvp -N $< +firmware=icebreaker_fw.hex

icebreaker.json: icebreaker.v ice40up5k_spram.v spimemio.v simpleuart.v picosoc.v ../picorv32.v
	yosys -ql icebreaker.log -p 'synth_ice40 -top icebreaker -json icebreaker.json' $^

icebreaker_tb.vvp: icebreaker_tb.v icebreaker.v ice40up5k_spram.v spimemio.v simpleuart.v picosoc.v ../picorv32.v spiflash.v
	iverilog -s testbench -o $@ $^ `yosys-config --datdir/ice40/cells_sim.v`

icebreaker_syn_tb.vvp: icebreaker_tb.v icebreaker_syn.v spiflash.v
	iverilog -s testbench -o $@ $^ `yosys-config --datdir/ice40/cells_sim.v`

icebreaker_syn.v: icebreaker.json
	yosys -p 'read_json icebreaker.json; write_verilog icebreaker_syn.v'

icebreaker.asc: icebreaker.pcf icebreaker.json
	nextpnr-ice40 --freq 13 --up5k --asc icebreaker.asc --pcf icebreaker.pcf --json icebreaker.json

icebreaker.bin: icebreaker.asc
	icetime -d up5k -c 12 -mtr icebreaker.rpt icebreaker.asc
	icepack icebreaker.asc icebreaker.bin

icebprog: icebreaker.bin icebreaker_fw.bin
	iceprog icebreaker.bin
	iceprog -o 1M icebreaker_fw.bin

icebprog_fw: icebreaker_fw.bin
	iceprog -o 1M icebreaker_fw.bin

icebreaker_sections.lds: sections.lds
	$(CROSS)cpp -P -DICEBREAKER -o $@ $^

icebreaker_fw.elf: icebreaker_sections.lds start.s firmware.c
	$(CROSS)gcc $(CFLAGS) -DICEBREAKER -mabi=ilp32 -march=rv32ic -Wl,-Bstatic,-T,icebreaker_sections.lds,--strip-debug -ffreestanding -nostdlib -o icebreaker_fw.elf start.s firmware.c

icebreaker_fw.hex: icebreaker_fw.elf
	$(CROSS)objcopy -O verilog icebreaker_fw.elf icebreaker_fw.hex

icebreaker_fw.bin: icebreaker_fw.elf
	$(CROSS)objcopy -O binary icebreaker_fw.elf icebreaker_fw.bin

# ---- EPC5 5G-85K Evaluation Board ----

ecp5evnsim: ecp5evn_tb.vvp ecp5evn_fw.hex
	vvp -N $< +firmware=ecp5evn_fw.hex

ecp5evnsynsim: ecp5evn_syn_tb.vvp ecp5evn_fw.hex
	vvp -N $< +firmware=ecp5evn_fw.hex

ecp5evn.json: ecp5evn.v spimemio.v simpleuart.v picosoc.v ../picorv32.v
	yosys -ql ecp5evn.log -p "synth_ecp5 -top ecp5evn -json $@" $^

ecp5evn_tb.vvp: ecp5evn_tb.v ecp5evn.v spimemio.v simpleuart.v picosoc.v ../picorv32.v spiflash.v
	iverilog -I`yosys-config --datdir`/ecp5 -s testbench -o $@ $^ `yosys-config --datdir/ecp5/cells_sim.v --datdir/ecp5/cells_bb.v`

ecp5evn_syn_tb.vvp: ecp5evn_tb.v ecp5evn_syn.v spiflash.v
	iverilog -I`yosys-config --datdir`/ecp5 -s testbench -o $@ $^ `yosys-config --datdir/ecp5/cells_sim.v --datdir/ecp5/cells_bb.v`

ecp5evn_syn.v: ecp5evn_tb.json
	yosys -p 'read_json ecp5evn_tb.json; write_verilog ecp5evn_syn.v'

ecp5evn_tb.json: ecp5evn.v spimemio.v simpleuart.v picosoc.v ../picorv32.v
	yosys -ql ecp5evn.log -D SIM -p "synth_ecp5 -top ecp5evn -json $@" $^

ecp5evn_out.config: ecp5evn.lpf ecp5evn.json
	nextpnr-ecp5 --um5g-85k --package CABGA381 --json ecp5evn.json --textcfg $@ --lpf ecp5evn.lpf

ecp5evn.bit: ecp5evn_out.config
	ecppack $< $@

ecp5evnprog: ecp5evn.bit ecp5evn_fw.bin
	openFPGALoader -f ecp5evn.bit
	openFPGALoader -f -o 0x00200000 ecp5evn_fw.bin

ecp5evnprog_bit: ecp5evn.bit
	openFPGALoader -f ecp5evn.bit

ecp5evnprog_fw: ecp5evn_fw.bin
	openFPGALoader -f -o 0x00200000 ecp5evn_fw.bin

ecp5evn_sections.lds: sections.lds
	$(CROSS)cpp -P -DECP5EVN -o $@ $^

ecp5evn_fw.elf: ecp5evn_sections.lds start.s firmware.c
	$(CROSS)gcc $(CFLAGS) -mabi=ilp32 -DECP5EVN -march=rv32i -Wl,-Bstatic,-T,ecp5evn_sections.lds,--strip-debug -ffreestanding -nostdlib -o ecp5evn_fw.elf start.s firmware.c

ecp5evn_fw.hex: ecp5evn_fw.elf
	$(CROSS)objcopy -O verilog ecp5evn_fw.elf ecp5evn_fw.hex

ecp5evn_fw.bin: ecp5evn_fw.elf
	$(CROSS)objcopy -O binary ecp5evn_fw.elf ecp5evn_fw.bin

# ---- ULX3S 85K Evaluation Board ----

ulx3ssim: ulx3s_tb.vvp ulx3s_fw.hex
	vvp -N $< +firmware=ulx3s_fw.hex

ulx3ssynsim: ulx3s_syn_tb.vvp ulx3s_fw.hex
	vvp -N $< +firmware=ulx3s_fw.hex

ulx3s.json: ulx3s.v spimemio.v simpleuart.v picosoc.v ../picorv32.v
	yosys -ql ulx3s.log -p "synth_ecp5 -top ulx3s -json $@" $^

ulx3s_tb.vvp: ulx3s_tb.v ulx3s.v spimemio.v simpleuart.v picosoc.v ../picorv32.v spiflash.v
	iverilog -I`yosys-config --datdir`/ecp5 -s testbench -o $@ $^ `yosys-config --datdir/ecp5/cells_sim.v --datdir/ecp5/cells_bb.v`

ulx3s_syn_tb.vvp: ulx3s_tb.v ulx3s_syn.v spiflash.v
	iverilog -I`yosys-config --datdir`/ecp5 -s testbench -o $@ $^ `yosys-config --datdir/ecp5/cells_sim.v --datdir/ecp5/cells_bb.v`

ulx3s_syn.v: ulx3s_tb.json
	yosys -p 'read_json ulx3s_tb.json; write_verilog ulx3s_syn.v'

ulx3s_tb.json: ulx3s.v spimemio.v simpleuart.v picosoc.v ../picorv32.v
	yosys -ql ulx3s.log -D SIM -p "synth_ecp5 -top ulx3s -json $@" $^

ulx3s_out.config: ulx3s.lpf ulx3s.json
	nextpnr-ecp5 --85k --package CABGA381 --json ulx3s.json --textcfg $@ --lpf ulx3s.lpf

ulx3s.bit: ulx3s_out.config
	ecppack $< $@

ulx3sprog: ulx3s.bit ulx3s_fw.bin
	openFPGALoader -b ulx3s -f ulx3s.bit
	openFPGALoader -b ulx3s -f -o 0x00200000 ulx3s_fw.bin

ulx3sprog_bit: ulx3s.bit
	openFPGALoader -b ulx3s -f ulx3s.bit

ulx3sprog_fw: ulx3s_fw.bin
	openFPGALoader -b ulx3s -f -o 0x00200000 ulx3s_fw.bin

ulx3s_sections.lds: sections.lds
	$(CROSS)cpp -P -DULX3S -o $@ $^

ulx3s_fw.elf: ulx3s_sections.lds start.s firmware.c
	$(CROSS)gcc $(CFLAGS) -mabi=ilp32 -DULX3S -march=rv32i -Wl,-Bstatic,-T,ulx3s_sections.lds,--strip-debug -ffreestanding -nostdlib -o ulx3s_fw.elf start.s firmware.c

ulx3s_fw.hex: ulx3s_fw.elf
	$(CROSS)objcopy -O verilog ulx3s_fw.elf ulx3s_fw.hex

ulx3s_fw.bin: ulx3s_fw.elf
	$(CROSS)objcopy -O binary ulx3s_fw.elf ulx3s_fw.bin

# ---- iCE40 iCESugar Board ----
# icessim: icesugar_tb.vvp icesugar_fw.hex
# 	vvp -N $< +firmware=icesugar_fw.hex

icessynsim: icesugar_syn_tb.vvp icesugar_fw.hex
	vvp -N $< +firmware=icesugar_fw.hex

icesugar.json: icesugar.v ice40up5k_spram.v spimemio.v simpleuart.v picosoc.v ../picorv32.v
	yosys -ql icesugar.log -p 'synth_ice40 -top icesugar -json icesugar.json' $^

icesugar_tb.vvp: icesugar_tb.v icesugar.v ice40up5k_spram.v spimemio.v simpleuart.v picosoc.v ../picorv32.v spiflash.v
	iverilog -s testbench -o $@ $^ `yosys-config --datdir/ice40/cells_sim.v`

icesugar_syn_tb.vvp: icesugar_tb.v icesugar_syn.v spiflash.v
	iverilog -s testbench -o $@ $^ `yosys-config --datdir/ice40/cells_sim.v`

icesugar_syn.v: icesugar.json
	yosys -p 'read_json icesugar.json; write_verilog icesugar_syn.v'

icesugar.asc: icesugar.pcf icesugar.json
	nextpnr-ice40 --freq 13 --up5k --asc icesugar.asc --pcf icesugar.pcf --json icesugar.json

icesugar.bin: icesugar.asc
	icetime -d up5k -c 12 -mtr icesugar.rpt icesugar.asc
	icepack icesugar.asc icesugar.bin

ICELINK_DIR=$(shell df | grep iCELink | awk '{print $$6}')
${warning iCELink path: $(ICELINK_DIR)}

icessim: 
	@nextpnr-ice40 --freq 13 --up5k --pcf icesugar.pcf --json icesugar.json --package sg48 --gui


icesprog: icesugar.bin icesugar_fw.bin
	@echo  "icesprog"
	icesprog icesugar.bin
	icesprog -o 0x100000 icesugar_fw.bin
	@#truncate -s 1048576 icesugar.bin
	@#@cat icesugar.bin icesugar_fw.bin > icesugar_spiflash.bin
	@#if [ -d '$(ICELINK_DIR)' ]; \
        #then \
            #cp icesugar.bin $(ICELINK_DIR); \
        #else \
            #echo "iCELink not found"; \
            #exit 1; \
    #fi

icesimg: icesugar.bin icesugar_fw.bin
	truncate -s 1048576 icesugar.bin
	cat icesugar.bin icesugar_fw.bin > picorv32.bin

icesugar_sections.lds: sections.lds
	$(CROSS)cpp -P -DICEBREAKER -o $@ $^

icesugar_fw.elf: icesugar_sections.lds start.s firmware.c
	$(CROSS)gcc $(CFLAGS) -DICEBREAKER -march=rv32ic -Wl,-Bstatic,-T,icesugar_sections.lds,--strip-debug -ffreestanding -nostdlib -o icesugar_fw.elf start.s firmware.c

icesugar_fw.hex: icesugar_fw.elf
	$(CROSS)objcopy -O verilog icesugar_fw.elf icesugar_fw.hex

icesugar_fw.bin: icesugar_fw.elf
	$(CROSS)objcopy -O binary icesugar_fw.elf icesugar_fw.bin

# ---- Testbench for SPI Flash Model ----

spiflash_tb: spiflash_tb.vvp firmware.hex
	vvp -N $<

spiflash_tb.vvp: spiflash.v spiflash_tb.v
	iverilog -s testbench -o $@ $^

# ---- ASIC Synthesis Tests ----

cmos.log: spimemio.v simpleuart.v picosoc.v ../picorv32.v
	yosys -l cmos.log -p 'synth -top picosoc; abc -g cmos2; opt -fast; stat' $^

# ---- Clean ----

clean:
	rm -f testbench.vvp testbench.vcd spiflash_tb.vvp spiflash_tb.vcd
	rm -f hx8kdemo_fw.elf hx8kdemo_fw.hex hx8kdemo_fw.bin cmos.log
	rm -f icebreaker_fw.elf icebreaker_fw.hex icebreaker_fw.bin
	rm -f hx8kdemo.json hx8kdemo.log hx8kdemo.asc hx8kdemo.rpt hx8kdemo.bin
	rm -f hx8kdemo_syn.v hx8kdemo_syn_tb.vvp hx8kdemo_tb.vvp
	rm -f icebreaker.json icebreaker.log icebreaker.asc icebreaker.rpt icebreaker.bin
	rm -f icebreaker_syn.v icebreaker_syn_tb.vvp icebreaker_tb.vvp
	rm -f ecp5evn_fw.elf ecp5evn_fw.hex ecp5evn_fw.bin
	rm -f ecp5evn.json ecp5evn.log ecp5evn.bit ecp5evn_out.config
	rm -f ecp5evn_tb.json ecp5evn_tb.vvp ecp5evn_syn_tb.vvp ecp5evn_syn.v
	rm -f ulx3s_fw.elf ulx3s_fw.hex ulx3s_fw.bin
	rm -f ulx3s.json ulx3s.log ulx3s.bit ulx3s_out.config
	rm -f ulx3s_tb.json ulx3s_tb.vvp ulx3s_syn_tb.vvp ulx3s_syn.v
	rm -f icesugar.asc icesugar.bin icesugar.json icesugar.log
	rm -f icesugar.rpt icesugar_fw.bin icesugar_fw.elf picorv32.bin

.PHONY: spiflash_tb clean
.PHONY: hx8kprog hx8kprog_fw hx8ksim hx8ksynsim
.PHONY: icebprog icebprog_fw icebsim icebsynsim
.PHONY: ecp5evnprog ecp5evnprog_fw ecp5evnsim ecp5evnsynsim
.PHONY: ulx3sprog ulx3sprog_fw ulx3ssim ulx3ssynsim
.PHONY: icesprog icesprog_fw icessim icessynsim icesimg
