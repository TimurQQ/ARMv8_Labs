#include "lab5.h"

unsigned char* executor(unsigned char* img, unsigned char* invert_img, int width, int height, int channels)
{
	int img_size = width * height * channels;
	for(unsigned char *p = img, *pg = invert_img; p != img + img_size; p+= channels, pg += channels)
	{
		*pg = 255 - *p;
		*(pg + 1) = 255 - *(p + 1);
		*(pg + 2) = 255 - *(p + 2);
	}
	return (invert_img);
}
