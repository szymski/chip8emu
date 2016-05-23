module chip8emu.keyboard;

class Keyboard {
	
	bool[16] keys;

	bool opIndex(ubyte key) {
		assert(key < 16, "Key index must be less than 16.");

		return keys[key];
	}

}