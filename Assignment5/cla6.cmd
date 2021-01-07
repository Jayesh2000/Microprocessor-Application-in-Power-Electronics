/* cla6.cmd */
MEMORY
{
        TEXT :  ORIGIN = 0x008800, LENGTH = 0x200
	DATA :	ORIGIN = 0x008A00, LENGTH = 0x010
	CLA_PMEM  :	ORIGIN = 0x00A800, LENGTH = 0x400
	CLA_DMEM  :	ORIGIN = 0x00A000, LENGTH = 0x400
}

SECTIONS
{
        .text :         { *(.text) } > TEXT
	.data :		{ *(.data) } > DATA
	cla_pmem   :		{ *(cla_pmem) } > CLA_PMEM
	cla_dmem   :		{ *(cla_dmem) } > CLA_DMEM
}
