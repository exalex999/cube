# cube
The program renders (using central projection) a cube of specified position and rotation angles relative to coordinate axes. MIPS32, x86 and x86-64 are available. MIPS32 version gets the required coordinates from file and writes the rendered image to another file. Bresenham’s line approximation algorithm is used.
In x86 and x86-64 versions user steers the cube’s position using keyboard and gets rendered images in real-time on the screen. SDL2 library is required.

USAGE:

1. MIPS32 version:
  1) in cubecfg.txt configuration file define cube's position and rotation according to the following syntax:
    x y z
    cos(angleX) sin(angleX)
    cos(angleY) sin(angleY)
    cos(angleZ) sin(angleZ)
  2) in main.asm file define the const ifname determining the path to config.txt
  3) execute the program using MARS MIPS simulator
  4) enter a path for output image
2. x86-x64 version;
  1) execute program
  2) move the cube using A,F,S,W,D,E keys;
  3) rotate the cube using H,L,J,U,K,I keys.
