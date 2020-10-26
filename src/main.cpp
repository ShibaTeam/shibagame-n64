#include <string>
#include <cmath>

struct video_interface {
	uint32_t STATUS;
	uint32_t ORIGIN;
	uint32_t H_WIDTH;
	uint32_t V_INTR;
	uint32_t V_CURRENT_LINE;
	uint32_t V_TIMING;
	uint32_t V_SYNC;
	uint32_t H_SYNC;
	uint32_t H_SYNC_LEAP;
	uint32_t H_VIDEO;
	uint32_t V_VIDEO;
	uint32_t V_BURST;
	uint32_t X_SCALE;
	uint32_t Y_SCALE;
};


static constexpr size_t width { 320 };
static constexpr size_t height { 240 };

struct pixel {
	uint16_t r : 5;
	uint16_t g : 5;
	uint16_t b : 5;
	uint16_t : 0;
};

volatile static video_interface* VI = (video_interface*)0xa4400000;
static pixel* framebuffer = (pixel*)0x80700000;

template<class T>
T lerp(T f, float a, float b)
{
    return a + f * (b - a);
}

static void draw() {
	for(int x=0;x<width;x++)
    {
        for(int y=0;y<height;y++)
        {
            auto &colour = framebuffer[y * width + x];
            colour = { std::rand(), std::rand() , std::rand() };
        }
    }
}

extern "C" int main() {
	VI->STATUS = 0x3246;
	VI->ORIGIN = reinterpret_cast<uint32_t>(framebuffer);
	VI->H_WIDTH = width;

	VI->V_INTR = 0x2;
	VI->V_CURRENT_LINE = 0;
	VI->V_TIMING = 0x3e52239;
	VI->V_SYNC = 0x20d;
	VI->H_SYNC = 0xc15;
	VI->H_SYNC_LEAP = 0xc150c15UL;
	VI->H_VIDEO = 0x6c02ec;
	VI->V_VIDEO = 0x2501ff;
	VI->V_BURST = 0xe0204;
	VI->X_SCALE = 0x200;
	VI->Y_SCALE = 0x400;

	for(;;) {
		draw();
	}

	exit(EXIT_SUCCESS);
}
