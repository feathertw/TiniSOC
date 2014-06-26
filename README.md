All rights reserved by fea.

TinySOC
=======

TinySOC is a hardware system including a CPU, BUS, MEMORY, PERIPHERAL, WRAPPER and so on.
Most TinySOC code is written by verilog and pre-syn run in iverilog.
This project is motivated by a class homework and interest.
The goal is to provide a hardware system that have basic components and
there are kernel mode and user mode in CPU that can be used in a basic operation system.
TinySOC project can run with TinyOS project and TinyRUN project.

Characteristics of TinySOC
==========================

* The CPU ISR refer [AndesStar Instruction Set Architecture](http://goo.gl/Cctf5n) and STM32.

* The BUS architecture refer AMBA2 Advanced High-Performance Bus(AHB).

* MEMORY include Instruction Memory(IM) and Data Memory(DM).

* PERIPHERAL include a UART, but it's only have registers to store the value.

* WRAPPER for connect components to BUS.


TinySOC-CPU
===========

* 5 stage pipeline
* forwarding and hazard detection
* write-through cache
* jump cache
* branch prediction
* kernel mode and user mode
* interrupt handle
* systick timer


VECTOR TABLE
============
```
	0x0000_0000	Reset_Handler
	0x0000_0004	Syscall_Handler
	0x0000_0008	Systick_Handler
```


SYSTEM REGISTER
===============
for opcode mtsr and mfsr
```
	$PSW	SYSTEM_MODE	(RW) 0:kernelmode 1:usermode
	$IPSW	IRET_MODE	(RW) 0:kernelmode 1:usermode
	$P_P0	KSP		(R)  Kernel Stack Point
	$P_P1	USP		(R)  User Stack Point
```

MEMORY MAPPING
==============
Preserved
```
	IM	0x0000_0000	0x0100_0000
	DM	0x0100_0000	0x0200_0000
	UART	0x0200_0000	0x0300_0000
	SYSTEM	0x0E00_0000	0x0F00_0000
```
Mapping
```
	IM	0x0000_0000	0x0004_0000
	DM	0x0100_0000	0x0104_0000
	UART	0x0200_0000	TX_ENABLE
		0x0200_0004	RX_ENABLE
		0x0200_0010	TX_FLAG
		0x0200_0014	RX_FLAG
		0x0200_0020	TX_DATA
		0x0200_0024	RX_DATA
		0x0200_0030	BAUD_RATE
	SISTICK	0x0E10_0000	SISTICK_CONTROL
		0x0E10_0000[0]	ENABLE
		0x0E10_0000[1]	CLEAR
		0x0E10_0000[2]	CONTINUOUS
		0x0E10_0004	SISTICK_RELOAD_VALUE
		0x0E10_1000	SISTICK_STATUS(R)
		0x0E10_1000[0]	FLAG(R)
		0x0E10_1004	SISTICK_CURRENT_VALUE(R)
```

INTERRUPT BACK REGISTER
=======================
	original mode stack address - 32
```
	R0
	R1
	R2
	R3
	FP(R28)
	GP(R29)
	LP(R30)
	PC
```
	original mode stack high address

