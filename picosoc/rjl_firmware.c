/*
 *  PicoSoC - A simple example SoC using PicoRV32
 *
 *  Copyright (C) 2017  Clifford Wolf <clifford@clifford.at>
 *
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */

#include <stdint.h>
#include <stdbool.h>

// a pointer to this is a null pointer, but the compiler does not
// know that because "sram" is a linker symbol from sections.lds.
extern uint32_t sram;

#define reg_leds (*(volatile uint32_t*)0x03000000)
#define reg_new_pmod_leds (*(volatile uint32_t*)0x04000000)

// --------------------------------------------------------

extern uint32_t flashio_worker_begin;
extern uint32_t flashio_worker_end;

void delay() {
	uint32_t cycles_begin, cycles_now, cycles = 0;
	__asm__ volatile ("rdcycle %0" : "=r"(cycles_begin));
	while (cycles < 12000000) {
		__asm__ volatile ("rdcycle %0" : "=r"(cycles_now));
		cycles = cycles_now - cycles_begin;
	}
}

void activity_indicator_red_on() {
	reg_new_pmod_leds |= 1;
}

void activity_indicator_green_on() {
	reg_new_pmod_leds |= 2;
}

void activity_indicator_red_off() {
	reg_new_pmod_leds &= ~1;
}

void activity_indicator_green_off() {
	reg_new_pmod_leds &= ~2;
}

void activity_indicator_red() {
	activity_indicator_red_on();
	activity_indicator_green_off();
}

void activity_indicator_green() {
	activity_indicator_green_on();
	activity_indicator_red_off();
}

void report_led_on() {
	reg_new_pmod_leds |= 4;
}

void report_led_off() {
	reg_new_pmod_leds &= ~4;
}

void all_leds_off() {
	reg_leds = 0;
	reg_new_pmod_leds = 0;
}

void nonblocking_activity_indicator() {
	static enum states {red, green, invalid_state} state = red;
	static uint32_t time_of_last_state_change = 0;
	const unsigned int period = 2000000; // 12 000 000 per second
	uint32_t now;

	// The cycle counter is only 32 bits and ticks 12 million
	// times a second, so expect it to roll over about every
	// five minutes. That's acceptable, for now.

	__asm__ volatile ("rdcycle %0" : "=r"(now));
	if (now - time_of_last_state_change > period) {
		switch(state) {
			case red:
				activity_indicator_green();
				state = green;
				break;
			case green:
				activity_indicator_red();
				state = red;
			default:
				state = red;
				break;
		}
		time_of_last_state_change = now;
	}
}

void nonblocking_sense_and_report() {
	if (reg_new_pmod_leds & 1) {
		report_led_on();
	}
	else {
		report_led_off();
	}
}

void main() {
	all_leds_off(0);
	while(1) {
		nonblocking_activity_indicator();
		nonblocking_sense_and_report();
	}
}

