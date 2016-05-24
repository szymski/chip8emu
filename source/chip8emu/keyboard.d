module chip8emu.keyboard;

import derelict.sdl2.sdl;

private const int[] keymap = [
	SDL_SCANCODE_0,
	SDL_SCANCODE_1,
	SDL_SCANCODE_2,
	SDL_SCANCODE_3,
	SDL_SCANCODE_4,
	SDL_SCANCODE_5,
	SDL_SCANCODE_6,
	SDL_SCANCODE_7,
	SDL_SCANCODE_8,
	SDL_SCANCODE_9,
	SDL_SCANCODE_A,
	SDL_SCANCODE_B,
	SDL_SCANCODE_C,
	SDL_SCANCODE_D,
	SDL_SCANCODE_E,
	SDL_SCANCODE_F,
];

class Keyboard {
	
	bool[16] keys;

	bool opIndex(ubyte key) {
		assert(key < 16, "Key index must be less than 16.");

		return keys[key];
	}

	void update() {
		auto sdlKeys = SDL_GetKeyboardState(null);
		
		foreach(i, key; keymap)
			keys[i] = sdlKeys[key] > 0;
	}

}