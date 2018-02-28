#pragma once

#include <stdint.h>

enum BLE_LIFE_CLOCK_STATE{
	BLE_LIFE_CLOCK_STATE_TIME = 0,
	BLE_LIFE_CLOCK_STATE_COUNTDOWN,
	BLE_LIFE_CLOCK_STATE_DATE,
	BLE_LIFE_CLOCK_STATE_STOPWATCH,
	BLE_LIFE_CLOCK_STATE_BATTERY,
	BLE_LIFE_CLOCK_STATE_CAMERA,
	BLE_LIFE_CLOCK_STATE_WEATHER,
	BLE_LIFE_CLOCK_STATE_FIRMWARE,
	BLE_LIFE_CLOCK_STATE_ABOUT,
	BLE_LIFE_CLOCK_STATE_MAX
};

enum BLE_LIFE_CLOCK_ANIMATION{
	BLE_LIFE_CLOCK_ANIMATION_SCROLL_RIGHT = 0,				// Scroll from left
	BLE_LIFE_CLOCK_ANIMATION_SCROLL_LEFT,					// Scroll from right
	BLE_LIFE_CLOCK_ANIMATION_FADE_IN,						// Fade in all required segments
	BLE_LIFE_CLOCK_ANIMATION_FADE_OUT,						// Fade out all required segments
	BLE_LIFE_CLOCK_ANIMATION_FADE_OUT_UNWANTED,				// Start with all segments lit, fade out unwanted
	BLE_LIFE_CLOCK_ANIMATION_SEQUENCE_SEGMENT_BY_SEGMENT,	// Build display segment by segment (left to right)
	BLE_LIFE_CLOCK_ANIMATION_RANDOM_SEGMENT_BY_SEGMENT,		// Build display segment by segment (random)
	BLE_LIFE_CLOCK_ANIMATION_RANDOM_SEGMENT_FLASHING,		// Random segments flashing, build up one by one.
	BLE_LIFE_CLOCK_ANIMATION_SLOT_MACHINE,					// Slot machine effect display by display
	BLE_LIFE_CLOCK_ANIMATION_ROLL_IN_TOP,					// Roll in from bottom
	BLE_LIFE_CLOCK_ANIMATION_ROLL_IN_BOTTOM,				// Roll in from top
	BLE_LIFE_CLOCK_ANIMATION_EXPAND,						// Expand from center
	BLE_LIFE_CLOCK_ANIMATION_SCROLL,						// Scroll in from edge
	BLE_LIFE_CLOCK_ANIMATION_TRANSFORM_BLINK,				// Nixie Tube Video - transformBlink
	BLE_LIFE_CLOCK_ANIMATION_TRANSFORM_HALF,				// Nixie Tube Video - transformHalf
	BLE_LIFE_CLOCK_ANIMATION_TRANSFORM_AND,					// Nixie Tube Video - transformAnd
	BLE_LIFE_CLOCK_ANIMATION_TRANSFORM_OR,					// Nixie Tube Video - transformOr
	BLE_LIFE_CLOCK_ANIMATION_TRANSFORM_ROLL,				// Nixie Tube Video - transformRoll
	BLE_LIFE_CLOCK_ANIMATION_TRANSFORM_ONE_THIRD,			// Nixie Tube Video - transformOneThird
};

enum BLE_LIFE_CLOCK_SCROLL_SPEED{
	BLE_LIFE_CLOCK_SCROLL_SPEED_IMMEDIATE = 0,
	BLE_LIFE_CLOCK_SCROLL_SPEED_FADE_IN,
	BLE_LIFE_CLOCK_SCROLL_SPEED_RANDOM,
};

enum BLE_LIFE_CLOCK_TIME_FORMAT{
	BLE_LIFE_CLOCK_TIME_FORMAT_12H = 0,
	BLE_LIFE_CLOCK_TIME_FORMAT_24H,
};

enum BLE_LIFE_CLOCK_TIMEZONE_FORMAT{
	BLE_LIFE_CLOCK_TIMEZONE_FORMAT_0 = 0,
	BLE_LIFE_CLOCK_TIMEZONE_FORMAT_1,
	BLE_LIFE_CLOCK_TIMEZONE_FORMAT_2,
};

enum BLE_LIFE_CLOCK_WRIST_CONFIGURATION{
	BLE_LIFE_CLOCK_WRIST_CONFIGURATION_LEFT_HAND = 0,
	BLE_LIFE_CLOCK_WRIST_CONFIGURATION_RIGHT_HAND,
};

enum BLE_LIFE_CLOCK_CASE_MATERIAL{
	BLE_LIFE_CLOCK_CASE_MATERIAL_BRASS = 0,
	BLE_LIFE_CLOCK_CASE_MATERIAL_STEEL,
	BLE_LIFE_CLOCK_CASE_MATERIAL_TITANIUM,
};

enum BLE_LIFE_CLOCK_VERSION{
	BLE_LIFE_CLOCK_VERSION_DEV = 0,
	BLE_LIFE_CLOCK_VERSION_ONE,
};

enum BLE_LIFE_CLOCK_PACKET_TYPE{
	BLE_LIFE_CLOCK_PACKET_TYPE_CONFIGURATION = 0,
	BLE_LIFE_CLOCK_PACKET_TYPE_CONFIGURATION_REQUEST
};

#pragma pack(push,1)

typedef struct{
	struct{
		uint8_t duration;
		uint8_t animation : 5;
		uint8_t scroll_speed : 3;
	}state_animations[BLE_LIFE_CLOCK_STATE_MAX];
	uint8_t	time_format : 1;
	uint8_t tz_format : 2;
	uint8_t wrist_config : 1;
	uint8_t case_material : 3;
}ble_life_clock_configuration_t;

typedef struct{
	uint8_t	version : 2;
	uint8_t type : 6;
	union{
		ble_life_clock_configuration_t configuration;
	}payload;
}ble_life_clock_packet_t;

#pragma pack(pop)

#ifndef BLE_LIFE_CLOCK_PROTOCOL_ONLY
#include <stdbool.h>

#include "ble.h"
#include "ble_srv_common.h"

typedef struct ble_life_clock ble_life_clock_t;

typedef void (*ble_life_clock_on_recv_t)(ble_life_clock_t* s, const ble_life_clock_packet_t* packet);

struct ble_life_clock{
    ble_gatts_char_handles_t		tx_handles;
    ble_gatts_char_handles_t		rx_handles;
    uint16_t						conn_handle;
    bool							is_notification_enabled;
    ble_life_clock_on_recv_t		on_recv;
};

uint32_t ble_life_clock_init(ble_life_clock_t* s, ble_life_clock_on_recv_t on_recv, ble_uuid_t* service_uuid);

void ble_life_clock_on_ble_evt(ble_life_clock_t* s, ble_evt_t* evt);

uint32_t ble_life_clock_send(ble_life_clock_t* s, const ble_life_clock_packet_t* packet);

#endif
