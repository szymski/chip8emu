module chip8emu.screen;

import std.random, std.conv;

interface IScreen {
	ubyte width();
	ubyte height();
	void setPixel(ubyte x, ubyte y, bool active);
	bool opIndex(ubyte x, ubyte y);
	void opIndexAssign(bool value, ubyte x, ubyte y);
	bool drawFromBytes(ubyte x, ubyte y, ubyte[] pixels);
	void clear();
	ubyte* dataPointer();
}

final class CHIP8Screen : IScreen {

	ubyte[64][32] buffer;

	ubyte width() {
		return 64;
	}

	ubyte height() {
		return 32;
	}

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

	ubyte* dataPointer() {
		return cast(ubyte*)buffer.ptr;
	}

}

final class SUPERCHIP8Screen : IScreen {
	
	ubyte[128][64] buffer;
	
	ubyte width() {
		return 128;
	}
	
	ubyte height() {
		return 64;
	}
	
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
	
	ubyte* dataPointer() {
		return cast(ubyte*)buffer.ptr;
	}
	
}
