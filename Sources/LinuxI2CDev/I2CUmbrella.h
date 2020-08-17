#ifdef __APPLE__
// the I2C headers are fairly self contained; it is possible to stub them here
#include "linux-headers/linux/types.h"
#include "linux-headers/linux/i2c.h"
#include "linux-headers/linux/i2c-dev.h"
#else
#include <linux/types.h>
#include <linux/i2c.h>
#include <linux/i2c-dev.h>
#endif
