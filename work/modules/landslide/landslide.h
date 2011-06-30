/**
 * @file landslide.h
 * @brief common landslide stuff
 * @author Ben Blum
 */

#ifndef __LS_LANDSLIDE_H
#define __LS_LANDSLIDE_H

#include <simics/api.h>

#ifdef CAUSE_TIMER_LOLOL
#include "sp_table.h"
#endif

#define MODULE_NAME "landslide"

typedef struct {
	/* log_object_t must be the first thing in the device struct */
	log_object_t log;

	int trigger_count;

	/* Pointers to relevant objects. Currently only supports one CPU. */
	conf_object_t *cpu0;
	conf_object_t *kbd0;

#ifdef CAUSE_TIMER_LOLOL
	struct sp_table active_threads;
#endif

	/* scheduler state below - TODO: refactor */
	int current_thread;
} ls_state_t;

#endif