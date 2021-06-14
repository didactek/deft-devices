#ifdef __APPLE__
// the SPI headers are fairly self contained; it is possible to stub them here
#include "linux-headers/linux/types.h"
#include "linux-headers/linux/ioctl.h"
#include "linux-headers/linux/spi/spidev.h"
#else
#include <linux/spi/spidev.h>
#endif

// Swift's import of modulemap's PCM macros is incomplete, so the idiom is to
// bridge as a C type using the macro in its definition:
static unsigned long const kSPI_IOC_WR_MAX_SPEED_HZ = SPI_IOC_WR_MAX_SPEED_HZ;
static unsigned long const kSPI_IOC_WR_MODE = SPI_IOC_WR_MODE;

// Bridging a parameterized macro is more complicated, but since Deft's use of
// write only needs to send one packet, SPI_IOC_MESSAGE can be hardcoded
// with that parameter:

/// SPI_IOC_MESSAGE(1)
static unsigned long const kSPI_IOC_MESSAGE_1 = SPI_IOC_MESSAGE(1);
