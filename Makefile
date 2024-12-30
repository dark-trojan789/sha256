# Makefile
SIM ?= icarus
TOPLEVEL_LANG ?= verilog

# Verilog sources
VERILOG_SOURCES += $(PWD)/hdl/wrappers/wrapper.v

export PYTHONPATH := $(PWD)/tb

# Test targets for each wrapper module
small_sigma_0:
	rm -rf sim_build
	$(MAKE) sim MODULE=tb_small_sigma_0 TOPLEVEL=s0_wrapper

small_sigma_1:
	rm -rf sim_build
	$(MAKE) sim MODULE=tb_small_sigma_1 TOPLEVEL=s1_wrapper

big_sigma_0:
	rm -rf sim_build
	$(MAKE) sim MODULE=tb_big_sigma_0 TOPLEVEL=S0_wrapper

big_sigma_1:
	rm -rf sim_build
	$(MAKE) sim MODULE=tb_big_sigma_1 TOPLEVEL=S1_wrapper

ch:
	rm -rf sim_build
	$(MAKE) sim MODULE=tb_ch TOPLEVEL=ch_wrapper

maj:
	rm -rf sim_build
	$(MAKE) sim MODULE=tb_maj TOPLEVEL=maj_wrapper

w_new:
	rm -rf sim_build
	$(MAKE) sim MODULE=tb_w_new TOPLEVEL=w_new_wrapper

w_generator:
	rm -rf sim_build
	$(MAKE) sim MODULE=tb_w_generator TOPLEVEL=w_generator_wrapper

sha256:
	rm -rf sim_build
	$(MAKE) sim MODULE=tb_sha256 TOPLEVEL=sha256_wrapper
all: small_sigma_0 small_sigma_1 big_sigma_0 big_sigma_1 ch maj w_new w_generator

# Include cocotb makefile
include $(shell cocotb-config --makefiles)/Makefile.sim
