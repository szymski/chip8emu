import std.stdio, chip8emu.emulator;

void main()
{
	auto emulator = new Chip8Emulator();
	emulator.loadProgram("programs/INVADERS");
	emulator.start();
	emulator.start();
}
