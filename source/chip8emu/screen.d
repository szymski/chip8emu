module chip8emu.screen;

import std.random;

final class Screen {
	
	ubyte[64][32] buffer;

	void setPixel(ubyte x, ubyte y, bool active) {
		assert(x < 64, "X must be less than 64");
		assert(y < 32, "Y must be less than 32");
		
		buffer[y][x] = active ? 0xFF : 0x00;
	}

	bool opIndex(ubyte x, ubyte y) {
		assert(x < 64, "X must be less than 64");
		assert(y < 32, "Y must be less than 32");

		return buffer[y][x] == 0xFF;
	}

	void opIndexAssign(bool value, ubyte x, ubyte y) {
		setPixel(x, y, value);
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

	void drawFromBytes(ubyte x, ubyte y, ubyte[] pixels) {
		foreach(line; pixels) {
			for(int x1 = 0; x1 < 8; x1++)
				this[cast(ubyte)(x + x1) % 64, y % 32] = ((line >> (7 - x1)) & 1) == 1;
			y++;
		}
	}

}