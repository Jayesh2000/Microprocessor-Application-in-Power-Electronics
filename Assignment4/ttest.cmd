MEMORY
{
	TEXT:	ORIGIN = 0x008800, LENGTH = 0x200
}

SECTIONS
{
	.text:	{*(.text)} > TEXT
}
