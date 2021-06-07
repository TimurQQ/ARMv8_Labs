#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#ifndef IMAGE
#define IMAGE

unsigned char* executor(unsigned char * img, unsigned char * gray_img, int width, int height, int channels);
unsigned char* executor_asm(unsigned char * img, unsigned char * gray_img, int width, int height, int channels);

#endif
