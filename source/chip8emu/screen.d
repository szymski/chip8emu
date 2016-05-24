module chip8emu.screen;

import std.random, std.conv;

final class Screen {
	
	ushort width = 64, height = 32;
	ubyte[64][32] buffer;

	void setPixel(ubyte x, ubyte y, bool active) {
		assert(x < width, "X must be less than " ~ width.to!string);
		assert(y < height, "Y must be less than " ~ height.to!string);
		
		buffer[y][x] = active ? 0xFF : 0x00;
	}

	bool opIndex(ubyte x, ubyte y) {
		assert(x < width, "X must be less than " ~ width.to!string);
		assert(y < height, "Y must be less than " ~ height.to!string);

		return buffer[y][x] == 0xFF;
	}

	void opIndexAssign(bool value, ubyte x, ubyte y) {
		setPixel(x, y, value);
	}

	void clear() {
		foreach(y; 0 .. height)
			foreach(x; 0 .. width)
				setPixel(cast(ubyte)x, cast(ubyte)y, false);
	}

	void randomize() {
		foreach(y; 0 .. height)
			foreach(x; 0 .. width)
				setPixel(cast(ubyte)x, cast(ubyte)y, uniform(0, 2) == 1);
	}

	bool drawFromBytes(ubyte x, ubyte y, ubyte[] pixels) {
		bool collision = false;

		foreach(line; pixels) {
			for(int x1 = 0; x1 < 8; x1++) {
				if((((line >> (7 - x1)) & 1) == 1) && this[cast(ubyte)(x + x1) % width, y % height])
					collision = true;
				this[cast(ubyte)(x + x1) % width, y % height] = this[cast(ubyte)(x + x1) % width, y % height] ^ (((line >> (7 - x1)) & 1) == 1);
			}
			y++;
		}

		return collision;
	}

}