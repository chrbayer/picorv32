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

#define reg_leds (*(volatile uint32_t *)0x03000000)
#define reg_mmio (*(volatile uint32_t *)0x06000000)

// raven
#define reg_fp_gpio_data (*(volatile uint32_t*)0x07000000)
#define reg_fp_gpio_ena (*(volatile uint32_t*)0x07000004)
#define reg_fp_gpio_pu (*(volatile uint32_t*)0x07000008)
#define reg_fp_gpio_pd (*(volatile uint32_t*)0x0700000c)

// --------------------------------------------------------

void delay(unsigned long microseconds) {
	unsigned long delay_in_cycles = microseconds * 12;

	uint32_t cycles_begin, cycles_now, cycles = 0;
	__asm__ volatile ("rdcycle %0" : "=r"(cycles_begin));
	while (cycles < (uint32_t)delay) {
		__asm__ volatile ("rdcycle %0" : "=r"(cycles_now));
		cycles = cycles_now - cycles_begin;
	}
}

// The following are mapped to 0x03 (gpio)
#define red_breakoff_pmod_led (1<<5)
#define activity_red_led (1<<11)
#define activity_green_led (1<<12)
#define red_inbuilt_led (1<<6)
#define green_inbuilt_led (1<<7)

#define red_diffuse_led_reg reg_leds
#define red_diffuse_led_bit (1<<10)

// The following are mapped to 0x06 (mmio)
// (the reset button is sensible on bit 0)
#define green_superbright_led_reg reg_mmio
#define green_superbright_led_bit (1<<1)
#define red_breakoff_pmod_led_reg reg_mmio
#define red_breakoff_pmod_led_bit (1<<2)

// The following are mapped to 0x07 (fp_gpio)

void activity_indicator_red_on() {
	reg_leds |= activity_red_led;
}

void activity_indicator_green_on() {
	reg_leds |= activity_green_led;
}

void activity_indicator_red_off() {
	reg_leds &= ~activity_red_led;
}

void activity_indicator_green_off() {
	reg_leds &= ~activity_green_led;
}

void report_led_on() {
	red_diffuse_led_reg |= red_diffuse_led_bit;
}

void report_led_off() {
	red_diffuse_led_reg &= ~red_diffuse_led_bit;
}

void green_superbright_led_on() {
	green_superbright_led_reg |= green_superbright_led_bit;
}

void green_superbright_led_off() {
	green_superbright_led_reg &= ~green_superbright_led_bit;
}

void flash_green_superbright_led() {
	green_superbright_led_on();
	delay(500000); // usec
	green_superbright_led_off();
	delay(500000); // usec
}

void activity_indicator_red() {
	activity_indicator_red_on();
	activity_indicator_green_off();
}

void activity_indicator_green() {
	activity_indicator_green_on();
	activity_indicator_red_off();
}

void green_inbuilt_led_on() {
	reg_leds |= green_inbuilt_led;
}

void green_inbuilt_led_off() {
	reg_leds &= ~green_inbuilt_led;
}

void red_inbuilt_led_on() {
	reg_leds |= red_inbuilt_led;
}

void red_inbuilt_led_off() {
	reg_leds &= ~red_inbuilt_led;
}

void inbuilt_activity_indicator_red() {
	red_inbuilt_led_on();
	green_inbuilt_led_off();
}

void inbuilt_activity_indicator_green() {
	red_inbuilt_led_off();
	green_inbuilt_led_on();
}

void all_leds_off() {
	reg_leds = 0;
}

void nonblocking_activity_indicator() {
	static enum states {red, green, invalid_state} state = red;
	static uint32_t time_of_last_state_change = 0;
	const unsigned int period = 2500000; // 12 000 000 per second
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
				break;
			default:
				state = red;
				break;
		}
		time_of_last_state_change = now;
	}
}

void inbuilt_activity_indicator() {
	static enum states {red, green, invalid_state} state = red;
	static uint32_t time_of_last_state_change = 0;
	const unsigned int period = 3300000; // 12 000 000 per second
	uint32_t now;

	// The cycle counter is only 32 bits and ticks 12 million
	// times a second, so expect it to roll over about every
	// five minutes. That's acceptable, for now.

	__asm__ volatile ("rdcycle %0" : "=r"(now));
	if (now - time_of_last_state_change > period) {
		switch(state) {
			case red:
				inbuilt_activity_indicator_green();
				state = green;
				break;
			case green:
				inbuilt_activity_indicator_red();
				state = red;
				break;
			default:
				state = red;
				break;
		}
		time_of_last_state_change = now;
	}
}

void nonblocking_1s_counter() {
	static enum states {on, off, invalid_state} state = off;
	static uint32_t time_of_last_state_change = 0;
	uint32_t now;
	const unsigned long one_second = 12000000; // cycles

	// The cycle counter is only 32 bits and ticks 12 million
	// times a second, so expect it to roll over about every
	// five minutes. That's acceptable, for now.

	__asm__ volatile ("rdcycle %0" : "=r"(now));
	if (now - time_of_last_state_change > one_second) {
		switch(state) {
			case on:
				report_led_off();
				state = off;
				break;
			case off:
				report_led_on();
				state = on;
				break;
			default:
				state = on;
				break;
		}
		time_of_last_state_change = now;
	}
}

void experiment_with_extremely_short_interval() {
	static enum states {on, off, invalid_state} state = off;
	static uint32_t time_of_last_state_change = 0;
	uint32_t now;
	const unsigned long one_second = 12000000; // cycles
	const unsigned long on_time = 12000; // multiplication and div not allowed here
	const unsigned long off_time = one_second;

	// The cycle counter is only 32 bits and ticks 12 million
	// times a second, so expect it to roll over about every
	// five minutes. That's acceptable, for now.

	__asm__ volatile ("rdcycle %0" : "=r"(now));
	switch(state) {
		case on:
			if (now - time_of_last_state_change > on_time) {
				red_inbuilt_led_off();
				state = off;
				time_of_last_state_change = now;
			}
			break;
		case off:
			if (now - time_of_last_state_change > off_time) {
				red_inbuilt_led_on();
				state = on;
				time_of_last_state_change = now;
			}
			break;
		default:
			state = on;
			break;
	}
}

// It works!
void desperation() {
	if (reg_mmio & 1) {
		report_led_on();
	}
	else {
		report_led_off();
	}
}

// This worked!
void monitor_activity_red_as_a_memory_location(void) {
	if (reg_leds & activity_red_led) {
		report_led_on();
	}
	else {
		report_led_off();
	}
}

void sense_superbright_green_led() {
	if (green_superbright_led_reg & green_superbright_led_bit) {
		report_led_on();
	}
	else {
		report_led_off();
	}
}

void sense_red_diffuse_led() {
	if (red_diffuse_led_reg & red_diffuse_led_bit) {
		report_led_on();
	}
	else {
		report_led_off();
	}
}

void sense_red_breakoff_pmod_led() {
	if (red_breakoff_pmod_led_reg & red_breakoff_pmod_led_bit) {
		report_led_on();
	}
	else {
		report_led_off();
	}
}

void main() {
	all_leds_off();
	while(1) {
		nonblocking_activity_indicator();
		// experiment_with_extremely_short_interval();
		// nonblocking_1s_counter();
		// inbuilt_activity_indicator();
		// nonblocking_sense_and_report();
		// monitor_activity_red_as_a_memory_location();
		// desperation();
		sense_superbright_green_led();
		sense_red_breakoff_pmod_led();
	}
}

