# cube
The program renders (using central projection) a cube of specified position and rotation angles relative to coordinate axes. MIPS32, x86 and x86-64 are available. MIPS32 version gets the required coordinates from file and writes the rendered image to another file. Bresenham’s line approximation algorithm is used.
In x86 and x86-64 versions user steers the cube’s position using keyboard and gets rendered images in real-time on the screen. SDL2 library is required.
