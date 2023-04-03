# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  set C_S00_AXI_DATA_WIDTH [ipgui::add_param $IPINST -name "C_S00_AXI_DATA_WIDTH" -parent ${Page_0} -widget comboBox]
  set_property tooltip {Width of S_AXI data bus} ${C_S00_AXI_DATA_WIDTH}
  set C_S00_AXI_ADDR_WIDTH [ipgui::add_param $IPINST -name "C_S00_AXI_ADDR_WIDTH" -parent ${Page_0}]
  set_property tooltip {Width of S_AXI address bus} ${C_S00_AXI_ADDR_WIDTH}
  ipgui::add_param $IPINST -name "C_S00_AXI_BASEADDR" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S00_AXI_HIGHADDR" -parent ${Page_0}
  set C_S01_AXI_DATA_WIDTH [ipgui::add_param $IPINST -name "C_S01_AXI_DATA_WIDTH" -parent ${Page_0} -widget comboBox]
  set_property tooltip {Width of S_AXI data bus} ${C_S01_AXI_DATA_WIDTH}
  set C_S01_AXI_ADDR_WIDTH [ipgui::add_param $IPINST -name "C_S01_AXI_ADDR_WIDTH" -parent ${Page_0}]
  set_property tooltip {Width of S_AXI address bus} ${C_S01_AXI_ADDR_WIDTH}
  ipgui::add_param $IPINST -name "C_S01_AXI_BASEADDR" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S01_AXI_HIGHADDR" -parent ${Page_0}


}

proc update_PARAM_VALUE.Byte_bits { PARAM_VALUE.Byte_bits } {
	# Procedure called to update Byte_bits when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.Byte_bits { PARAM_VALUE.Byte_bits } {
	# Procedure called to validate Byte_bits
	return true
}

proc update_PARAM_VALUE.CIPHERTEXT_SZ { PARAM_VALUE.CIPHERTEXT_SZ } {
	# Procedure called to update CIPHERTEXT_SZ when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CIPHERTEXT_SZ { PARAM_VALUE.CIPHERTEXT_SZ } {
	# Procedure called to validate CIPHERTEXT_SZ
	return true
}

proc update_PARAM_VALUE.KYBER_512_CtBytes { PARAM_VALUE.KYBER_512_CtBytes } {
	# Procedure called to update KYBER_512_CtBytes when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.KYBER_512_CtBytes { PARAM_VALUE.KYBER_512_CtBytes } {
	# Procedure called to validate KYBER_512_CtBytes
	return true
}

proc update_PARAM_VALUE.KYBER_512_PKBytes { PARAM_VALUE.KYBER_512_PKBytes } {
	# Procedure called to update KYBER_512_PKBytes when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.KYBER_512_PKBytes { PARAM_VALUE.KYBER_512_PKBytes } {
	# Procedure called to validate KYBER_512_PKBytes
	return true
}

proc update_PARAM_VALUE.KYBER_512_RandBytes { PARAM_VALUE.KYBER_512_RandBytes } {
	# Procedure called to update KYBER_512_RandBytes when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.KYBER_512_RandBytes { PARAM_VALUE.KYBER_512_RandBytes } {
	# Procedure called to validate KYBER_512_RandBytes
	return true
}

proc update_PARAM_VALUE.KYBER_512_SKBytes { PARAM_VALUE.KYBER_512_SKBytes } {
	# Procedure called to update KYBER_512_SKBytes when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.KYBER_512_SKBytes { PARAM_VALUE.KYBER_512_SKBytes } {
	# Procedure called to validate KYBER_512_SKBytes
	return true
}

proc update_PARAM_VALUE.KYBER_512_SSBytes { PARAM_VALUE.KYBER_512_SSBytes } {
	# Procedure called to update KYBER_512_SSBytes when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.KYBER_512_SSBytes { PARAM_VALUE.KYBER_512_SSBytes } {
	# Procedure called to validate KYBER_512_SSBytes
	return true
}

proc update_PARAM_VALUE.KYBER_K { PARAM_VALUE.KYBER_K } {
	# Procedure called to update KYBER_K when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.KYBER_K { PARAM_VALUE.KYBER_K } {
	# Procedure called to validate KYBER_K
	return true
}

proc update_PARAM_VALUE.KYBER_N { PARAM_VALUE.KYBER_N } {
	# Procedure called to update KYBER_N when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.KYBER_N { PARAM_VALUE.KYBER_N } {
	# Procedure called to validate KYBER_N
	return true
}

proc update_PARAM_VALUE.KYBER_Q { PARAM_VALUE.KYBER_Q } {
	# Procedure called to update KYBER_Q when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.KYBER_Q { PARAM_VALUE.KYBER_Q } {
	# Procedure called to validate KYBER_Q
	return true
}

proc update_PARAM_VALUE.PUBLIC_KEY_SZ { PARAM_VALUE.PUBLIC_KEY_SZ } {
	# Procedure called to update PUBLIC_KEY_SZ when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PUBLIC_KEY_SZ { PARAM_VALUE.PUBLIC_KEY_SZ } {
	# Procedure called to validate PUBLIC_KEY_SZ
	return true
}

proc update_PARAM_VALUE.RAND_SZ { PARAM_VALUE.RAND_SZ } {
	# Procedure called to update RAND_SZ when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RAND_SZ { PARAM_VALUE.RAND_SZ } {
	# Procedure called to validate RAND_SZ
	return true
}

proc update_PARAM_VALUE.SECRET_KEY_SZ { PARAM_VALUE.SECRET_KEY_SZ } {
	# Procedure called to update SECRET_KEY_SZ when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SECRET_KEY_SZ { PARAM_VALUE.SECRET_KEY_SZ } {
	# Procedure called to validate SECRET_KEY_SZ
	return true
}

proc update_PARAM_VALUE.SHARED_SECRET_SZ { PARAM_VALUE.SHARED_SECRET_SZ } {
	# Procedure called to update SHARED_SECRET_SZ when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SHARED_SECRET_SZ { PARAM_VALUE.SHARED_SECRET_SZ } {
	# Procedure called to validate SHARED_SECRET_SZ
	return true
}

proc update_PARAM_VALUE.C_S00_AXI_DATA_WIDTH { PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to update C_S00_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXI_DATA_WIDTH { PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to validate C_S00_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S00_AXI_ADDR_WIDTH { PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to update C_S00_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXI_ADDR_WIDTH { PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to validate C_S00_AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S00_AXI_BASEADDR { PARAM_VALUE.C_S00_AXI_BASEADDR } {
	# Procedure called to update C_S00_AXI_BASEADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXI_BASEADDR { PARAM_VALUE.C_S00_AXI_BASEADDR } {
	# Procedure called to validate C_S00_AXI_BASEADDR
	return true
}

proc update_PARAM_VALUE.C_S00_AXI_HIGHADDR { PARAM_VALUE.C_S00_AXI_HIGHADDR } {
	# Procedure called to update C_S00_AXI_HIGHADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXI_HIGHADDR { PARAM_VALUE.C_S00_AXI_HIGHADDR } {
	# Procedure called to validate C_S00_AXI_HIGHADDR
	return true
}

proc update_PARAM_VALUE.C_S01_AXI_DATA_WIDTH { PARAM_VALUE.C_S01_AXI_DATA_WIDTH } {
	# Procedure called to update C_S01_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S01_AXI_DATA_WIDTH { PARAM_VALUE.C_S01_AXI_DATA_WIDTH } {
	# Procedure called to validate C_S01_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S01_AXI_ADDR_WIDTH { PARAM_VALUE.C_S01_AXI_ADDR_WIDTH } {
	# Procedure called to update C_S01_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S01_AXI_ADDR_WIDTH { PARAM_VALUE.C_S01_AXI_ADDR_WIDTH } {
	# Procedure called to validate C_S01_AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S01_AXI_BASEADDR { PARAM_VALUE.C_S01_AXI_BASEADDR } {
	# Procedure called to update C_S01_AXI_BASEADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S01_AXI_BASEADDR { PARAM_VALUE.C_S01_AXI_BASEADDR } {
	# Procedure called to validate C_S01_AXI_BASEADDR
	return true
}

proc update_PARAM_VALUE.C_S01_AXI_HIGHADDR { PARAM_VALUE.C_S01_AXI_HIGHADDR } {
	# Procedure called to update C_S01_AXI_HIGHADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S01_AXI_HIGHADDR { PARAM_VALUE.C_S01_AXI_HIGHADDR } {
	# Procedure called to validate C_S01_AXI_HIGHADDR
	return true
}


proc update_MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S00_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S00_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S01_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_S01_AXI_DATA_WIDTH PARAM_VALUE.C_S01_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S01_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_S01_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S01_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_S01_AXI_ADDR_WIDTH PARAM_VALUE.C_S01_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S01_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_S01_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.KYBER_K { MODELPARAM_VALUE.KYBER_K PARAM_VALUE.KYBER_K } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.KYBER_K}] ${MODELPARAM_VALUE.KYBER_K}
}

proc update_MODELPARAM_VALUE.KYBER_N { MODELPARAM_VALUE.KYBER_N PARAM_VALUE.KYBER_N } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.KYBER_N}] ${MODELPARAM_VALUE.KYBER_N}
}

proc update_MODELPARAM_VALUE.KYBER_Q { MODELPARAM_VALUE.KYBER_Q PARAM_VALUE.KYBER_Q } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.KYBER_Q}] ${MODELPARAM_VALUE.KYBER_Q}
}

proc update_MODELPARAM_VALUE.Byte_bits { MODELPARAM_VALUE.Byte_bits PARAM_VALUE.Byte_bits } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.Byte_bits}] ${MODELPARAM_VALUE.Byte_bits}
}

proc update_MODELPARAM_VALUE.KYBER_512_SKBytes { MODELPARAM_VALUE.KYBER_512_SKBytes PARAM_VALUE.KYBER_512_SKBytes } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.KYBER_512_SKBytes}] ${MODELPARAM_VALUE.KYBER_512_SKBytes}
}

proc update_MODELPARAM_VALUE.KYBER_512_PKBytes { MODELPARAM_VALUE.KYBER_512_PKBytes PARAM_VALUE.KYBER_512_PKBytes } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.KYBER_512_PKBytes}] ${MODELPARAM_VALUE.KYBER_512_PKBytes}
}

proc update_MODELPARAM_VALUE.KYBER_512_CtBytes { MODELPARAM_VALUE.KYBER_512_CtBytes PARAM_VALUE.KYBER_512_CtBytes } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.KYBER_512_CtBytes}] ${MODELPARAM_VALUE.KYBER_512_CtBytes}
}

proc update_MODELPARAM_VALUE.KYBER_512_SSBytes { MODELPARAM_VALUE.KYBER_512_SSBytes PARAM_VALUE.KYBER_512_SSBytes } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.KYBER_512_SSBytes}] ${MODELPARAM_VALUE.KYBER_512_SSBytes}
}

proc update_MODELPARAM_VALUE.KYBER_512_RandBytes { MODELPARAM_VALUE.KYBER_512_RandBytes PARAM_VALUE.KYBER_512_RandBytes } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.KYBER_512_RandBytes}] ${MODELPARAM_VALUE.KYBER_512_RandBytes}
}

proc update_MODELPARAM_VALUE.RAND_SZ { MODELPARAM_VALUE.RAND_SZ PARAM_VALUE.RAND_SZ } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RAND_SZ}] ${MODELPARAM_VALUE.RAND_SZ}
}

proc update_MODELPARAM_VALUE.SECRET_KEY_SZ { MODELPARAM_VALUE.SECRET_KEY_SZ PARAM_VALUE.SECRET_KEY_SZ } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SECRET_KEY_SZ}] ${MODELPARAM_VALUE.SECRET_KEY_SZ}
}

proc update_MODELPARAM_VALUE.SHARED_SECRET_SZ { MODELPARAM_VALUE.SHARED_SECRET_SZ PARAM_VALUE.SHARED_SECRET_SZ } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SHARED_SECRET_SZ}] ${MODELPARAM_VALUE.SHARED_SECRET_SZ}
}

proc update_MODELPARAM_VALUE.PUBLIC_KEY_SZ { MODELPARAM_VALUE.PUBLIC_KEY_SZ PARAM_VALUE.PUBLIC_KEY_SZ } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PUBLIC_KEY_SZ}] ${MODELPARAM_VALUE.PUBLIC_KEY_SZ}
}

proc update_MODELPARAM_VALUE.CIPHERTEXT_SZ { MODELPARAM_VALUE.CIPHERTEXT_SZ PARAM_VALUE.CIPHERTEXT_SZ } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CIPHERTEXT_SZ}] ${MODELPARAM_VALUE.CIPHERTEXT_SZ}
}

