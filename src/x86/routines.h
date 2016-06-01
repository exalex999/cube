typedef struct
{
	double x, y, z;
} DPoint;
typedef struct
{
	DPoint p1, p2;
	int r, g, b;
} Line;

DPoint rotate(DPoint p, double cosfix, double sinfix, double cosfiy, double sinfiy, double cosfiz, double sinfiz);
DPoint move_project(DPoint p, double Tx, double Ty, double Tz, double camx, double camy, double camdis);
void sort_lines(Line* lines[12]);
