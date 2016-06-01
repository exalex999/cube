#include "SDL2/SDL.h"
#include "math.h"
#include "routines.h"

#define WIDTH		800
#define HEIGHT		480
#define	CAMDIS		400.0
#define	CAMX		400.0
#define	CAMY		240.0
#define	INIT_TX		400.0
#define	INIT_TY		240.0
#define	INIT_TZ		50.0
#define	TSTEP		1.0
#define FISTEP		0.01
#define	CBHLEN		100		// half cube edge length
#define	LNTHCK		5

int main(int argc, char *argv[])
{
	SDL_Init(SDL_INIT_VIDEO);
    SDL_Window *win = SDL_CreateWindow("cube", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, WIDTH, HEIGHT, 0);
    SDL_Renderer *renderer = SDL_CreateRenderer(win, -1, SDL_RENDERER_ACCELERATED);
    double Tx = INIT_TX, Ty = INIT_TY, Tz = INIT_TZ, sTx = 0.0, sTy = 0.0, sTz = 0.0, sfix = 0.0, sfiy = 0.0, sfiz = 0.0;
    DPoint points[8] = {{.x = -CBHLEN, .y = -CBHLEN, .z = -CBHLEN}, {.x = CBHLEN, .y = -CBHLEN, .z = -CBHLEN}, {.x = CBHLEN, .y = -CBHLEN, .z = CBHLEN}, {.x = -CBHLEN, .y = -CBHLEN, .z = CBHLEN}, {.x = -CBHLEN, .y = CBHLEN, .z = -CBHLEN}, {.x = CBHLEN, .y = CBHLEN, .z = -CBHLEN}, {.x = CBHLEN, .y = CBHLEN, .z = CBHLEN}, {.x = -CBHLEN, .y = CBHLEN, .z = CBHLEN}};
    Line* lines[12];
    int ifRerender = 1;
    for(int i = 0; i < 12; i++)
		lines[i] = (Line*)malloc(sizeof(Line));
    while (1)
    {
        SDL_Event e;
        if (SDL_PollEvent(&e))
        {
        	switch(e.type)
        	{
        	case SDL_KEYDOWN:
        		switch(e.key.keysym.scancode)
        		{
        		case SDL_SCANCODE_A:
        			ifRerender = 1;
        			sTx = -TSTEP;
        			break;
        		case SDL_SCANCODE_F:
        			ifRerender = 1;
        			sTx = TSTEP;
        			break;
        		case SDL_SCANCODE_D:
        			ifRerender = 1;
        			sTy = TSTEP;
        			break;
        		case SDL_SCANCODE_E:
        			ifRerender = 1;
        			sTy = -TSTEP;
        			break;
        		case SDL_SCANCODE_S:
        			ifRerender = 1;
        			sTz = -TSTEP;
        			break;
        		case SDL_SCANCODE_W:
        			ifRerender = 1;
        			sTz = TSTEP;
        			break;
        		case SDL_SCANCODE_K:
        			ifRerender = 1;
        			sfix = FISTEP;
        			break;
        		case SDL_SCANCODE_I:
        			ifRerender = 1;
        			sfix = -FISTEP;
        			break;
        		case SDL_SCANCODE_J:
        			ifRerender = 1;
        			sfiy = -FISTEP;
        			break;
        		case SDL_SCANCODE_L:
        			ifRerender = 1;
        			sfiy = FISTEP;
        			break;
        		case SDL_SCANCODE_O:
        			ifRerender = 1;
        			sfiz = FISTEP;
        			break;
        		case SDL_SCANCODE_U:
        			ifRerender = 1;
        			sfiz = -FISTEP;
        			break;
        		}
        		break;
        	case SDL_KEYUP:
        		switch(e.key.keysym.scancode)
        		{
        		case SDL_SCANCODE_A:
        		case SDL_SCANCODE_F:
        			sTx = 0.0;
        			break;
        		case SDL_SCANCODE_D:
        		case SDL_SCANCODE_E:
        			sTy = 0.0;
        			break;
        		case SDL_SCANCODE_S:
        		case SDL_SCANCODE_W:
        			sTz = 0.0;
        			break;
        		case SDL_SCANCODE_K:
        		case SDL_SCANCODE_I:
        			sfix = 0.0;
        			break;
        		case SDL_SCANCODE_J:
        		case SDL_SCANCODE_L:
        			sfiy = 0.0;
        			break;
        		case SDL_SCANCODE_O:
        		case SDL_SCANCODE_U:
        			sfiz = 0.0;
        			break;
        		}
        		if(!(sTx || sTy || sTz || sfix || sfiy || sfiz))
        			ifRerender = 0;
        		break;
        	}
		    if(e.type == SDL_QUIT)
		    	break;
        }
		if(ifRerender)
		{
			//ifRerender=0;
			Tx += sTx;
			Ty += sTy;
			Tz += sTz;
			if(sfix || sfiy || sfiz)
				for(int i = 0; i < 8; i++)
					points[i] = rotate(points[i], cos(sfix), sin(sfix), cos(sfiy), sin(sfiy), cos(sfiz), sin(sfiz));
			for(int i = 0; i < 12; i++)
			{
				lines[i]->g = (85*((i>>2) + 1));
				lines[i]->r = (i & 3) < 2 ? 127 : 255;
				lines[i]->b = i & 1 ? 127 : 255;
			}
			lines[0]->p1 = lines[1]->p1 = lines[2]->p1 = move_project(points[0], Tx, Ty, Tz, CAMX, CAMY, CAMDIS);
			lines[0]->p2 = lines[3]->p1 = lines[4]->p1 = move_project(points[1], Tx, Ty, Tz, CAMX, CAMY, CAMDIS);
			lines[3]->p2 = lines[5]->p1 = lines[6]->p1 = move_project(points[2], Tx, Ty, Tz, CAMX, CAMY, CAMDIS);
			lines[1]->p2 = lines[5]->p2 = lines[7]->p1 = move_project(points[3], Tx, Ty, Tz, CAMX, CAMY, CAMDIS);
			lines[2]->p2 = lines[8]->p1 = lines[9]->p1 = move_project(points[4], Tx, Ty, Tz, CAMX, CAMY, CAMDIS);
			lines[4]->p2 = lines[8]->p2 = lines[10]->p1 = move_project(points[5], Tx, Ty, Tz, CAMX, CAMY, CAMDIS);
			lines[6]->p2 = lines[10]->p2 = lines[11]->p1 = move_project(points[6], Tx, Ty, Tz, CAMX, CAMY, CAMDIS);
			lines[7]->p2 = lines[9]->p2 = lines[11]->p2 = move_project(points[7], Tx, Ty, Tz, CAMX, CAMY, CAMDIS);
			sort_lines(lines);
			SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
			SDL_RenderClear(renderer);
			for(int i = 0; i < 12; i++)
			{
				SDL_SetRenderDrawColor(renderer, lines[i]->r, lines[i]->g, lines[i]->b, 255);
				if(abs(lines[i]->p1.x - lines[i]->p2.x) < abs(lines[i]->p1.y - lines[i]->p2.y))
					for(int j = -LNTHCK/2; j < LNTHCK - LNTHCK/2; j++)
						SDL_RenderDrawLine(renderer, (int)lines[i]->p1.x + j, (int)lines[i]->p1.y, (int)lines[i]->p2.x + j, (int)lines[i]->p2.y);
				else
					for(int j = -LNTHCK/2; j < LNTHCK - LNTHCK/2; j++)
						SDL_RenderDrawLine(renderer, (int)lines[i]->p1.x, (int)lines[i]->p1.y + j, (int)lines[i]->p2.x, (int)lines[i]->p2.y + j);
			}
        	SDL_RenderPresent(renderer);
        }
    }
    for(int i = 0; i < 12; i++)
		free(lines[i]);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(win);
    SDL_Quit();
    return 0;
}
