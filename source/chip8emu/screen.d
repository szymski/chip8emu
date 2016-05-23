module chip8emu.screen;

import std.random;

final class Screen {
	
	ubyte[64][32] buffer;

	void setPixel(ubyte x, ubyte y, bool active) {
		assert(x < 64, "X must be less than 64");
		assert(y < 32, "Y must be less than 32");
		
		buffer[y][x] = active ? 0xFF : 0x00;
	}

	void clear() {
		foreach(y; 0 .. 32)
			foreach(x; 0 .. 64)
				setPixel(cast(ubyte)x, cast(ubyte)y, false);
	}

	void randomize() {
		foreach(y; 0 .. 32)
			foreach(x; 0 .. 64)
				setPixel(cast(ubyte)x, cast(ubyte)y, uniform(0, 2) == 1);
	}

}