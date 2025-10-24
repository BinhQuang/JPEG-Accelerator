transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+D:/HDL/JPEG {D:/HDL/JPEG/downsampler_420.v}
vlog -vlog01compat -work work +incdir+D:/HDL/JPEG {D:/HDL/JPEG/rgb2ycbcr.v}
vlog -vlog01compat -work work +incdir+D:/HDL/JPEG {D:/HDL/JPEG/quantizer_1.v}
vlog -vlog01compat -work work +incdir+D:/HDL/JPEG {D:/HDL/JPEG/dct_2d.v}
vlog -vlog01compat -work work +incdir+D:/HDL/JPEG {D:/HDL/JPEG/block_splitter.v}
vlog -vlog01compat -work work +incdir+D:/HDL/JPEG {D:/HDL/JPEG/entropy_encoder.v}
vlog -vlog01compat -work work +incdir+D:/HDL/JPEG {D:/HDL/JPEG/top_module_jpeg.v}

vlog -vlog01compat -work work +incdir+D:/HDL/JPEG {D:/HDL/JPEG/tb_top_module_jpeg.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneii_ver -L rtl_work -L work -voptargs="+acc"  tb_top_module_jpeg

add wave *
view structure
view signals
run -all
