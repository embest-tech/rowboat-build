#ifndef PRELINKMAP_H
#define PRELINKMAP_H

#include <sys/types.h>

extern void pm_init(const char *file);
extern void pm_report_library_size_in_memory(const char *name, off_t fsize);
extern unsigned pm_get_next_link_address(const char *name);

#ifdef MIPS_ADDRS
#define PRELINK_MIN 0x50000000
#define PRELINK_MAX 0x70000000
#else
#define PRELINK_MIN 0x90000000
#define PRELINK_MAX 0xB0000000
#endif


#endif/*PRELINKMAP_H*/
