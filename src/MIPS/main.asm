	.include	"macros.asm"
	
	# primal consts
	.eqv	WIDTH	800
	.eqv	HEIGHT	480
	.eqv	CAMDIS	400
	.eqv	CAMX	400
	.eqv	CAMY	240
	.eqv	INITX	400
	.eqv	INITY	240
	.eqv	INITZ	50
	.eqv	CBHLEN	100		# half cube edge length
	.eqv	DAP	16		# digits after point
	.eqv	LNTHCK	5
	.eqv	VTXC	0x00FFFFFF	# white
	.eqv	FNTTOPC	0x00FF0000	# red
	.eqv	FNTBTMC	0x000000FF	# blue
	.eqv	FNTLFTC	0x0000FFFF	# sky blue
	.eqv	FNTRGTC	0x00FFFF00	# yellow
	.eqv	TOPLFTC	0x00FF00FF	# magenta
	.eqv	TOPRGTC	0x00FF8000	# orange
	.eqv	BTMLFTC	0x00BB00FF	# violet
	.eqv	BTMRGTC	0x00804600	# brown
	.eqv	BCKTOPC	0x00006000	# dark green
	.eqv	BCKBTMC	0x00808080	# grey
	.eqv	BCKLFTC	0x00800000	# dark red
	.eqv	BCKRGTC	0x0000FF00	# green
	.eqv	MAXFNL	256		# max filename length
	# dependent consts
	.eqv	BMPSIZ	1152000		# 3*WIDTH*HEIGHT
	.eqv	FSIZ	1152054		# 14 + 40 + 3*BMPSIZ
	.eqv	MAXIFS	78		# 3*(max decimal length before point + 1 minus) + 6*(max decimal length after point + 1 minus + 1 dot) + 5 spaces + 3*(1 CR + 1 NL) + 1 end_symbol
	.eqv	RCAMDIS	0xA3		# 1/d = 0.0025, 16 bits after point
	.eqv	DBP	16		# digits after point
	.eqv	MASK	0x8000
	
	.data
	# header
h1:	.ascii	"BM"
h2:	.word	FSIZ, 0, 40, 40, 800, 480
	.half	1, 24
	.word	0, 0, 0, 0, 0, 0
bitmap: .space	BMPSIZ
	# matrixes 4*4 (*sizeof(word)=4)
	.align 2
mx1:	.space	64
mx2:	.space	64
mx3:	.space	64
mx4:	.space	64
vtx0:	.word	0, 0
vtx1:	.word	0, 0
vtx2:	.word	0, 0
vtx3:	.word	0, 0
vtx4:	.word	0, 0
vtx5:	.word	0, 0
vtx6:	.word	0, 0
vtx7:	.word	0, 0
ofname:	.space	MAXFNL
ifname:	.asciiz "/home/exalex/Documents/ARKO_Projects/cube_mips/cubecfg.txt"
ifcont:	.space	MAXIFS
msg1:	.asciiz	"Please enter output file path: "
msg2:	.asciiz "Done."

	.text
	.globl	main
main:
	# loading output filename
	li	$v0, 4
	la	$a0, msg1
	syscall
	li	$v0, 8
	la	$a0, ofname
	li	$a1, MAXFNL
	syscall
	move	$t0, $a0
nl_rm:
	lbu	$t1, ($t0)
	addiu	$t0, $t0, 1
	bge	$t1, ' ', nl_rm
	li	$t1, 0
	sb	$t1, -1($t0)
	# reading config file
	li	$v0, 13
	la	$a0, ifname
	li	$a1, 0
	syscall
	move	$a0, $v0
	li	$v0, 14
	la	$a1, ifcont
	li	$a2, MAXIFS
	syscall
	li	$v0, 16
	syscall
	# reading Tx, Ty, Tz
	la	$s0, ifcont
	int_read($s1, $s0, DAP)
	addiu	$s0, $s0, 1
	int_read($s2, $s0, DAP)
	addiu	$s0, $s0, 1
	int_read($s3, $s0, DAP)
	addiu	$s0, $s0, 1
	li	$s4, WIDTH
	sll	$s4, $s4, DAP
	srl	$s4, $s4, 1
	li	$s5, HEIGHT
	sll	$s5, $s5, DAP
	srl	$s5, $s5, 1
	subu	$s1, $s1, $s4
	subu	$s2, $s2, $s5
	li	$t0, CAMDIS
	sll	$t0, $t0, DAP
	addu	$s3, $s3, $t0
	li	$t0, INITX
	sll	$t0, $t0, DAP
	addu	$s1, $s1, $t0
	li	$t0, INITY
	sll	$t0, $t0, DAP
	addu	$s2, $s2, $t0
	li	$t0, INITZ
	sll	$t0, $t0, DAP
	addu	$s3, $s3, $t0
	# reading cos_fi_x, sin_fix
	frac_read($s6, $s0, DAP)
	addiu	$s0, $s0, 1
	frac_read($s7, $s0, DAP)
	addiu	$s0, $s0, 1
	# mx1 <- shift
	li	$t0, 1
	sll	$t0, $t0, DAP
	sw	$t0, mx1
	sw	$0, mx1 + 4
	sw	$0, mx1 + 8
	sw	$0, mx1 + 12
	sw	$0, mx1 + 16
	sw	$t0, mx1 + 20
	sw	$0, mx1 + 24
	sw	$0, mx1 + 28
	sw	$0, mx1 + 32
	sw	$0, mx1 + 36
	sw	$t0, mx1 + 40
	sw	$0, mx1 + 44
	sw	$s1, mx1 + 48
	sw	$s2, mx1 + 52
	sw	$s3, mx1 + 56
	sw	$t0, mx1 + 60
	# mx2 <- X-rotation
	negu	$t1, $s7
	sw	$t0, mx2
	sw	$0, mx2 + 4
	sw	$0, mx2 + 8
	sw	$0, mx2 + 12
	sw	$0, mx2 + 16
	sw	$s6, mx2 + 20
	sw	$s7, mx2 + 24
	sw	$0, mx2 + 28
	sw	$0, mx2 + 32
	sw	$t1, mx2 + 36
	sw	$s6, mx2 + 40
	sw	$0, mx2 + 44
	sw	$0, mx2 + 48
	sw	$0, mx2 + 52
	sw	$0, mx2 + 56
	sw	$t0, mx2 + 60
	# mx3 <- x-rotation * shift
	mx_mult(mx3, mx2, mx1, 4, 4, 4, 16, 16, DAP, DBP)
	# mx1 <- perspective
	li	$t0, 1
	sll	$t0, $t0, DAP
	sw	$t0, mx1
	sw	$0, mx1 + 4
	sw	$0, mx1 + 8
	sw	$0, mx1 + 12
	sw	$0, mx1 + 16
	sw	$t0, mx1 + 20
	sw	$0, mx1 + 24
	sw	$0, mx1 + 28
	sw	$0, mx1 + 32
	sw	$0, mx1 + 36
	sw	$t0, mx1 + 40
	li	$t1, RCAMDIS
	sw	$t1, mx1 + 44
	sw	$0, mx1 + 48
	sw	$0, mx1 + 52
	sw	$0, mx1 + 56
	sw	$0, mx1 + 60
	# mx2 <- x-rotation * shift * perspective
	mx_mult(mx2, mx3, mx1, 4, 4, 4, 16, 16, DAP, DBP)
	# mx1 <- shift_post_perspective
	li	$t0, 1
	sll	$t0, $t0, DAP
	sw	$t0, mx1
	sw	$0, mx1 + 4
	sw	$0, mx1 + 8
	sw	$0, mx1 + 12
	sw	$0, mx1 + 16
	sw	$t0, mx1 + 20
	sw	$0, mx1 + 24
	sw	$0, mx1 + 28
	sw	$0, mx1 + 32
	sw	$0, mx1 + 36
	sw	$t0, mx1 + 40
	sw	$0, mx1 + 44
	sw	$s4, mx1 + 48
	sw	$s5, mx1 + 52
	li	$t1, CAMDIS
	sll	$t1, $t1, DAP
	negu	$t1, $t1
	sw	$t1, mx1 + 56
	sw	$t0, mx1 + 60
	# mx3 <- x-rotation * shift * perspective * shift_post_perspective
	mx_mult(mx3, mx2, mx1, 4, 4, 4, 16, 16, DAP, DBP)
	# reading cos_fi_y, sin_fi_y
	frac_read($s6, $s0, DAP)
	addiu	$s0, $s0, 1
	frac_read($s7, $s0, DAP)
	addiu	$s0, $s0, 1
	# mx1 <- y-rotation
	li	$t0, 1
	sll	$t0, $t0, DAP
	sw	$s6, mx1
	sw	$0, mx1 + 4
	negu	$t1, $s7
	sw	$t1, mx1 + 8
	sw	$0, mx1 + 12
	sw	$0, mx1 + 16
	sw	$t0, mx1 + 20
	sw	$0, mx1 + 24
	sw	$0, mx1 + 28
	sw	$s7, mx1 + 32
	sw	$0, mx1 + 36
	sw	$s6, mx1 + 40
	sw	$0, mx1 + 44
	sw	$0, mx1 + 48
	sw	$0, mx1 + 52
	sw	$0, mx1 + 56
	sw	$t0, mx1 + 60
	# mx2 <- y-rotation * x-rotation * shift * perspective * shift_post_perspective
	mx_mult(mx2, mx1, mx3, 4, 4, 4, 16, 16, DAP, DBP)
	# reading cos_fi_y, sin_fi_y
	frac_read($s6, $s0, DAP)
	addiu	$s0, $s0, 1
	frac_read($s7, $s0, DAP)
	# mx1 <- z-rotation
	li	$t0, 1
	sll	$t0, $t0, DAP
	sw	$s6, mx1
	sw	$s7, mx1 + 4
	sw	$0, mx1 + 8
	sw	$0, mx1 + 12
	negu	$t1, $s7
	sw	$t1, mx1 + 16
	sw	$s6, mx1 + 20
	sw	$0, mx1 + 24
	sw	$0, mx1 + 28
	sw	$0, mx1 + 32
	sw	$0, mx1 + 36
	sw	$t0, mx1 + 40
	sw	$0, mx1 + 44
	sw	$0, mx1 + 48
	sw	$0, mx1 + 52
	sw	$0, mx1 + 56
	sw	$t0, mx1 + 60
	# mx3 <- transformation_matrix = z-rotation * y-rotation * x-rotation * shift * perspective * shift_post_perspective
	mx_mult(mx3, mx1, mx2, 4, 4, 4, 16, 16, DAP, DBP)
	# computing vtx0
	li	$s0, CBHLEN
	sll	$s0, $s0, DAP
	negu	$s1, $s0
	li	$s2, 1
	sll	$s2, $s2, DAP
	sw	$s1, mx2
	sw	$s1, mx2 + 4
	sw	$s1, mx2 + 8
	sw	$s2, mx2 + 12
	mx_mult(mx1, mx2, mx3, 1, 4, 4, 16, 4, DAP, DBP)
	lw	$s3, mx1
	lw	$s4, mx1 + 4
	lw	$s5, mx1 + 12
	fixp_div($s3, $s3, $s5, DAP)
	fixp_div($s4, $s4, $s5, DAP)
	round($s3, $s3, DAP, MASK)
	round($s4, $s4, DAP, MASK)
	sw	$s3, vtx0
	sw	$s4, vtx0 + 4
	# computing vtx1
	sw	$s0, mx2
	sw	$s1, mx2 + 4
	sw	$s1, mx2 + 8
	sw	$s2, mx2 + 12
	mx_mult(mx1, mx2, mx3, 1, 4, 4, 16, 4, DAP, DBP)
	lw	$s3, mx1
	lw	$s4, mx1 + 4
	lw	$s5, mx1 + 12
	fixp_div($s3, $s3, $s5, DAP)
	fixp_div($s4, $s4, $s5, DAP)
	round($s3, $s3, DAP, MASK)
	round($s4, $s4, DAP, MASK)
	sw	$s3, vtx1
	sw	$s4, vtx1 + 4
	# computing vtx2
	sw	$s0, mx2
	sw	$s1, mx2 + 4
	sw	$s0, mx2 + 8
	sw	$s2, mx2 + 12
	mx_mult(mx1, mx2, mx3, 1, 4, 4, 16, 4, DAP, DBP)
	lw	$s3, mx1
	lw	$s4, mx1 + 4
	lw	$s5, mx1 + 12
	fixp_div($s3, $s3, $s5, DAP)
	fixp_div($s4, $s4, $s5, DAP)
	round($s3, $s3, DAP, MASK)
	round($s4, $s4, DAP, MASK)
	sw	$s3, vtx2
	sw	$s4, vtx2 + 4
	# computing vtx3
	sw	$s1, mx2
	sw	$s1, mx2 + 4
	sw	$s0, mx2 + 8
	sw	$s2, mx2 + 12
	mx_mult(mx1, mx2, mx3, 1, 4, 4, 16, 4, DAP, DBP)
	lw	$s3, mx1
	lw	$s4, mx1 + 4
	lw	$s5, mx1 + 12
	fixp_div($s3, $s3, $s5, DAP)
	fixp_div($s4, $s4, $s5, DAP)
	round($s3, $s3, DAP, MASK)
	round($s4, $s4, DAP, MASK)
	sw	$s3, vtx3
	sw	$s4, vtx3 + 4
	# computing vtx4
	sw	$s1, mx2
	sw	$s0, mx2 + 4
	sw	$s1, mx2 + 8
	sw	$s2, mx2 + 12
	mx_mult(mx1, mx2, mx3, 1, 4, 4, 16, 4, DAP, DBP)
	lw	$s3, mx1
	lw	$s4, mx1 + 4
	lw	$s5, mx1 + 12
	fixp_div($s3, $s3, $s5, DAP)
	fixp_div($s4, $s4, $s5, DAP)
	round($s3, $s3, DAP, MASK)
	round($s4, $s4, DAP, MASK)
	sw	$s3, vtx4
	sw	$s4, vtx4 + 4
	# computing vtx5
	sw	$s0, mx2
	sw	$s0, mx2 + 4
	sw	$s1, mx2 + 8
	sw	$s2, mx2 + 12
	mx_mult(mx1, mx2, mx3, 1, 4, 4, 16, 4, DAP, DBP)
	lw	$s3, mx1
	lw	$s4, mx1 + 4
	lw	$s5, mx1 + 12
	fixp_div($s3, $s3, $s5, DAP)
	fixp_div($s4, $s4, $s5, DAP)
	round($s3, $s3, DAP, MASK)
	round($s4, $s4, DAP, MASK)
	sw	$s3, vtx5
	sw	$s4, vtx5 + 4
	# computing vtx6
	sw	$s0, mx2
	sw	$s0, mx2 + 4
	sw	$s0, mx2 + 8
	sw	$s2, mx2 + 12
	mx_mult(mx1, mx2, mx3, 1, 4, 4, 16, 4, DAP, DBP)
	lw	$s3, mx1
	lw	$s4, mx1 + 4
	lw	$s5, mx1 + 12
	fixp_div($s3, $s3, $s5, DAP)
	fixp_div($s4, $s4, $s5, DAP)
	round($s3, $s3, DAP, MASK)
	round($s4, $s4, DAP, MASK)
	sw	$s3, vtx6
	sw	$s4, vtx6 + 4
	# computing vtx7
	sw	$s1, mx2
	sw	$s0, mx2 + 4
	sw	$s0, mx2 + 8
	sw	$s2, mx2 + 12
	mx_mult(mx1, mx2, mx3, 1, 4, 4, 16, 4, DAP, DBP)
	lw	$s3, mx1
	lw	$s4, mx1 + 4
	lw	$s5, mx1 + 12
	fixp_div($s3, $s3, $s5, DAP)
	fixp_div($s4, $s4, $s5, DAP)
	round($s3, $s3, DAP, MASK)
	round($s4, $s4, DAP, MASK)
	sw	$s3, vtx7
	sw	$s4, vtx7 + 4
	# printing lines
	lw	$s0, vtx0
	lw	$s1, vtx0 + 4
	lw	$s2, vtx1
	lw	$s3, vtx1 + 4
	lw	$s4, vtx3
	lw	$s5, vtx3 + 4
	lw	$s6, vtx4
	lw	$s7, vtx4 + 4
	drln(bitmap, WIDTH, HEIGHT, $s0, $s1, $s2, $s3, LNTHCK, FNTBTMC, VTXC)
	drln(bitmap, WIDTH, HEIGHT, $s0, $s1, $s4, $s5, LNTHCK, BTMLFTC, VTXC)
	drln(bitmap, WIDTH, HEIGHT, $s0, $s1, $s6, $s7, LNTHCK, FNTLFTC, VTXC)
	lw	$s0, vtx7
	lw	$s1, vtx7 + 4
	drln(bitmap, WIDTH, HEIGHT, $s0, $s1, $s4, $s5, LNTHCK, BCKLFTC, VTXC)
	drln(bitmap, WIDTH, HEIGHT, $s0, $s1, $s6, $s7, LNTHCK, TOPLFTC, VTXC)
	lw	$s0, vtx5
	lw	$s1, vtx5 + 4
	drln(bitmap, WIDTH, HEIGHT, $s0, $s1, $s2, $s3, LNTHCK, FNTRGTC, VTXC)
	drln(bitmap, WIDTH, HEIGHT, $s0, $s1, $s6, $s7, LNTHCK, FNTTOPC, VTXC)
	lw	$s6, vtx6
	lw	$s7, vtx6 + 4
	drln(bitmap, WIDTH, HEIGHT, $s0, $s1, $s6, $s7, LNTHCK, TOPRGTC, VTXC)
	lw	$s0, vtx2
	lw	$s1, vtx2 + 4
	drln(bitmap, WIDTH, HEIGHT, $s0, $s1, $s2, $s3, LNTHCK, BTMRGTC, VTXC)
	drln(bitmap, WIDTH, HEIGHT, $s0, $s1, $s4, $s5, LNTHCK, BCKBTMC, VTXC)
	drln(bitmap, WIDTH, HEIGHT, $s0, $s1, $s6, $s7, LNTHCK, BCKRGTC, VTXC)
	lw	$s0, vtx7
	lw	$s1, vtx7 + 4
	drln(bitmap, WIDTH, HEIGHT, $s0, $s1, $s6, $s7, LNTHCK, BCKTOPC, VTXC)
	# writing BMP file
	li	$v0, 13
	la	$a0, ofname
	li	$a1, 1
	syscall
	move	$a0, $v0
	li	$v0, 15
	la	$a1, h1
	li	$a2, 2
	syscall
	li	$v0, 15
	la	$a1, h2
	li	$a2, 52
	syscall
	li	$v0, 15
	la	$a1, bitmap
	li	$a2, BMPSIZ
	syscall
	li	$v0, 16
	syscall
	#exit
	li	$v0, 4
	la	$a0, msg2
	syscall
	li	$v0, 10
	syscall
