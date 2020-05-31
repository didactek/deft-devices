#ifdef __APPLE__
// the SPI headers are fairly self contained; it is possible to stub them here
#include "linux-headers/linux/types.h"
#include "linux-headers/linux/ioctl.h"
#include "linux-headers/linux/spi/spidev.h"
#else
#include <linux/spi/spidev.h>
#define SPI_IOC_WR_MAX_SPEED_HZ 1074031364
#define SPI_IOC_WR_MODE 1073834753
#endif
