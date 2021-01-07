MEMORY
{
        TEXT :  ORIGIN = 0x008800, LENGTH = 0x200
	DATA :  ORIGIN = 0x008a00, LENGTH = 0x010
}

SECTIONS
{
        .text :         { *(.text) } > TEXT
	.data :		{ *(.data) } > DATA
}
