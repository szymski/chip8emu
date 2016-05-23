import std.stdio, chip8emu.emulator;

void main()
{
	auto emulator = new Chip8Emulator();
	emulator.start();
}
