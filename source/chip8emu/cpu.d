module chip8emu.cpu;

import std.array, std.random, std.conv, std.experimental.logger;
import chip8emu.screen, chip8emu.memory, chip8emu.keyboard;

/*
	CHIP-8 has 16, 8-bit registers (called from 0 to F) and one 16-bit register called I (mainly used to store memory addresses).
	F register should not be used by any program, because it is used a a flag by some instructions.

	The stack is an array of 16 16-bit values, used to store memory addresses.
*/

enum opCodesPerExecution = 10;

class Cpu {

	Memory memory;
	Screen screen;
	Keyboard keyboard;

	ushort pc;
	ubyte[16] registers;
	ushort I; 

	bool halt = false;

	ushort[16] stack;
	ushort sp;

	ubyte timerValue;
	ubyte soundTimerValue;

	this(Memory memory, Screen screen, Keyboard keyboard) {
		this.memory = memory;
		this.screen = screen;
		this.keyboard = keyboard;

		reset();
	}

	void reset() {
		halt = false;
		pc = 0x200;
		I = 0;
		sp = 0;
		registers[0 .. $] = 0;
		stack[0 .. $] = 0;
	}

	void performExecutionSteps() {
		foreach(i; 0 .. opCodesPerExecution)
			executeInstruction();
	}

	void executeInstruction() {
		if(halt)
			return;

		ushort opCode = nextOpCode();

		switch((opCode & 0xF000) >> 12) {

			// Jump to machine code 
			case 0x0:
				
				switch(opCode & 0x0FFF) {
				
					// Clear display
					case 0x0E0:
						screen.clear();
						break;

					// Return from a subroutine
					case 0x0EE:
						pc = stackPop();
						break;

					// Used only in old CHIP-8 computers.
					default:		
						break;

				}

				break;

			// Jump to address
			case 0x1:
				pc = getAddress(opCode);
				break;

			// Call subroutine
			case 0x2:
				stackPush(pc);
				pc = getAddress(opCode);
				break;

			// Skip next instruction if Vx = kk
			case 0x3:
				if(registers[(opCode & 0x0F00) >> 8] == (opCode & 0x00FF))
					pc += 2;
				break;

			// Skip next instruction if Vx != kk
			case 0x4:
				if(registers[(opCode & 0x0F00) >> 8] != (opCode & 0x00FF))
					pc += 2;
				break;

			// Skip next instruction if Vx == Vy
			case 0x5:
				if(registers[(opCode & 0x0F00) >> 8] == registers[(opCode & 0x00F0) >> 4])
					pc += 2;
				break;

			// Set Vx = kk
			case 0x6:
				registers[(opCode & 0x0F00) >> 8] = opCode & 0x00FF;
				break;

			// Set Vx = Vx + kk
			case 0x7:
				registers[(opCode & 0x0F00) >> 8] += opCode & 0x00FF;
				break;

			case 0x8:
				switch(opCode & 0x000F) {

					// Set Vx = Vy
					case 0x0:
						registers[(opCode & 0x0F00) >> 8] = registers[(opCode & 0x00F0) >> 4];
						break;

					// Set Vx = Vx OR Vy
					case 0x1:
						registers[(opCode & 0x0F00) >> 8] |= registers[(opCode & 0x00F0) >> 4];
						break;

					// Set Vx = Vx AND Vy
					case 0x2:
						registers[(opCode & 0x0F00) >> 8] &= registers[(opCode & 0x00F0) >> 4];
						break;

					// Set Vx = Vx XOR Vy
					case 0x3:
						registers[(opCode & 0x0F00) >> 8] ^= registers[(opCode & 0x00F0) >> 4];
						break;

					// Set Vx = Vx ADD Vy
					case 0x4:
						registers[(opCode & 0x0F00) >> 8] += registers[(opCode & 0x00F0) >> 4];
						// TODO: Carry flag
						break;

					// Set Vx = Vx SUB Vy
					case 0x5:
						registers[(opCode & 0x0F00) >> 8] -= registers[(opCode & 0x00F0) >> 4];
						// TODO: Borrow flag
						break;

					// Set Vx = Vx SHR x
					case 0x6:
						registers[(opCode & 0x0F00) >> 8] >>= registers[(opCode & 0x00F0) >> 4];
						// TODO: Byte checking
						break;

					// Set Vx = Vx SUBN Vy
					case 0x7:
						registers[(opCode & 0x0F00) >> 8] = cast(ubyte)(registers[(opCode & 0x00F0) >> 4] - registers[(opCode & 0x00F0) >> 8]);
						// TODO: Borrow flag
						break;

					// Set Vx = Vx SHL x
					case 0xE:
						registers[(opCode & 0x0F00) >> 8] <<= registers[(opCode & 0x00F0) >> 4];
						// TODO: Byte checking
						break;

					default:
						break;

				}
				break;

			// Skip next instruction if Vx != Vy
			case 0x9:
				if(registers[(opCode & 0x0F00) >> 8] != registers[(opCode & 0x00F0) >> 4])
					pc += 2;
				break;

			// Set I = nnn
			case 0xA:
				I = opCode & 0x0FFF;
				break;

			// Jump to nnn + V0
			case 0xB:
				pc = (opCode & 0x0FFF) + registers[0];
				break;

			// Set Vx = random byte AND kk
			case 0xC:
				registers[(opCode & 0x0F00) >> 8] = cast(ubyte)(uniform(0, 256) & opCode);
				break;

			// Draw n-byte sprite located in memory (I), at (Vx, Vy), set VF on collision
			case 0xD:
				ubyte x = registers[(opCode & 0x0F00) >> 8], y = registers[(opCode & 0x00F0) >> 4], height = opCode & 0x000F;

				ubyte[] data = memory.memory[I .. I + height];
				screen.drawFromBytes(x, y, data);

				// TODO: Collisions

				break;

			case 0xE:
				
				switch(opCode & 0x00FF) {
				
					// Skip next instruction, if key with the value of Vx is pressed
					case 0x9E:
						ubyte key = registers[(opCode & 0x0F00) >> 8];
						if(keyboard[key])
							pc += 2;
						break;

					// Skip next instruction, if key with the value of Vx is not pressed
					case 0xA1:
						ubyte key = registers[(opCode & 0x0F00) >> 8];
						if(!keyboard[key])
							pc += 2;
						break;
					
					default:
						break;

				}

				break;
			
			case 0xF:

				log("F");

				switch(opCode & 0x00FF) {

					// Set Vx = delay timer value
					case 0x07:
						registers[(opCode & 0x0F00) >> 8] = timerValue;
						break;

					// Wait for key press, value stored in Vx
					case 0x0A:
						// TODO: Wait for key press
						//registers[opCode & 0x0F00 >> 8] = ;
						break;

					// Set delay timer = Vx
					case 0x15:
						timerValue = registers[(opCode & 0x0F00) >> 8];
						break;

					// Set sound timer = Vx
					case 0x18:
						soundTimerValue = registers[(opCode & 0x0F00) >> 8];
						break;

					// Set I = I + Vx
					case 0x1E:
						I += registers[(opCode & 0x0F00) >> 8];
						break;

					// Set I = location of sprite for digit Vx
					case 0x29:
						log("asd");
						I = registers[(opCode & 0x0F00) >> 8] * 5;
						break;

					// Store BCD representation of Vx in memory locations I, I+1, and I+2
					case 0x33:
						// TODO: BCD storing
						break;

					// Store registers V0 through Vx in memory starting at location I
					case 0x55:
						for(int i = 0; i < ((opCode & 0x0F00) >> 8); i++)
							memory[cast(ushort)(I + i)] = registers[i];
						break;

					// Read registers V0 through Vx from memory starting at location I
					case 0x65:
						for(int i = 0; i < ((opCode & 0x0F00) >> 8); i++)
							registers[i] = memory[cast(ushort)(I + i)];
						break;

					default:
						break;

				}

				break;

			default:
				break;

		}

		if(pc > 4094)
			halt = true;
	}

	ushort nextOpCode() {
		auto opCode = memory[pc] << 8 | memory[cast(ushort)(pc + 1)];
		pc += 2;
		logf("%X", opCode);
		return cast(ushort)opCode;
	}

	ushort getAddress(ushort opCode) {
		return opCode & 0x0FFF;
	}

	void stackPush(ushort value) {
		assert(sp < 15, "Stack overflow.");

		sp++;
		stack[sp] = value;
	}

	ushort stackPop() {
		assert(sp > 0, "Stack pointer below 0.");

		auto value = stack[sp];
		sp--;
		return value;
	}

	void updateTimers() {
		if(timerValue > 0)
			timerValue--;
		if(soundTimerValue > 0)
			soundTimerValue--;
	}
}