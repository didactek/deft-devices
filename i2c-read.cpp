// i2c-read.cpp 
// 2020-05-05 kit transue
// use Linux userspace /dev/i2c- interface to read from TEA5767 radio, say?

#include <iostream>

#include <unistd.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#include <linux/i2c-dev.h>

int main() {
  long const radioAddress = 0x60;

  auto file = open("/dev/i2c-1", O_RDWR);
  ioctl(file, I2C_SLAVE, radioAddress);

  char buffer[6];
  auto bytesRead = read(file, buffer, sizeof(buffer));

  for (size_t i = 0; i < bytesRead; ++i) {
    std::cout << "0x" << std::hex << int(buffer[i]) << " ";
  }
  std::cout << std::endl;

  return 0;
}
