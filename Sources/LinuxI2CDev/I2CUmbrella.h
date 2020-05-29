#ifdef __APPLE__
// the I2C headers are fairly self contained; it is possible to stub them here
#else
#include <linux/types.h>
#include <linux/i2c.h>
#include <linux/i2c-dev.h>
#endif
