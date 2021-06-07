#include <time.h>
#include "lab5.h"
#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"

int main(int argc, char* argv[]) 
{
	if (argc != 4)
	{
		printf("Error number of args");
		return 1;
	}
	int width, height, channels;
	//file.jpg
	unsigned char *img = stbi_load(argv[1], &width, &height, &channels, 0);
	if (img == NULL) {
		printf("Error in loading the image\n");
		return 1;
	}
	printf("Width %dpx height %dpx channels %d\n", width, height, channels);

	int img_size = width * height * channels;
	unsigned char *invert_c_img = malloc(img_size*sizeof(unsigned char*));

	if(invert_c_img == NULL) 
	{
		printf("Unable to allocate memory for the invert C image\n");
		return 1;
	}
	int t = clock();
	invert_c_img = executor(img, invert_c_img, width, height, channels);
	t = clock() - t;
	printf("c: %d ms\n",t);
	// fout_c.jpg
	stbi_write_jpg(argv[2], width, height, channels, invert_c_img, 100);

	unsigned char *invert_asm_img = malloc(img_size*sizeof(unsigned char*));
	if (invert_asm_img == NULL)
	{
		printf("Unable to allocate memory for the invert asm image\n");
		return 1;
	}
	t = clock();
	invert_asm_img = executor_asm(img, invert_asm_img, width, height, channels);
	t = clock() - t;
	printf("asm: %d ms\n", t);
	// fout_asm.jpg
	stbi_write_jpg(argv[3], width, height, channels, invert_asm_img, 100);
	stbi_image_free(img);
	free(invert_c_img);
	free(invert_asm_img);
	return 0;
}
