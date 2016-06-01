	.eqv	ZERPONE	0x1999999A		# binary fraction part of 0.1
	
	# $name - register
	# %namel - label
	# %namei - immidiate
	
	# reads decimal number integer part starting from $i (iterator; should point to '-' or leftmost digit) and writes it to $d assuming $d is a fixed-point number with %dapi binary digits after the point
	.macro	int_read($d, $i, %dapi)
	li	$d, 0
	lbu	$t1, ($i)		# symbol pointed by iterator
	li	$t0, 0			# number sign: 0 - '+', 1 - '-'
	bne	$t1, '-', nminus_int_read
	li	$t0, 1			# number sign: 0 - '+', 1 - '-'
	addiu	$i, $i, 1
	lbu	$t1, ($i)
	j	convert_int_read
nminus_int_read:
	bne	$t1, '+', convert_int_read
	addiu	$i, $i, 1
	lbu	$t1, ($i)
convert_int_read:
	subiu	$t1, $t1, '0'
	addu	$d, $d, $t1
	addiu	$i, $i, 1
	lbu	$t1, ($i)		# new symbol
	blt	$t1, '0', numbend_int_read
	bgt	$t1, '9', numbend_int_read
	mulu	$d, $d, 10
	j	convert_int_read
numbend_int_read:
	sll	$d, $d, %dapi		# int->fixed-point
	beqz	$t0, pos_int_read	# if negative
	negu	$d, $d
pos_int_read:
	.end_macro
	
	# reads decimal number fraction part starting from $i (iterator; should point to '-', ' ' or '.') and writes it to $d assuming $d is a fixed-point number with %dapi binary digits after the point
	.macro	frac_read($d, $i, %dapi)
	li	$d, 0
	li	$t0, 0			# number sign: 0 - '+', 1 - '-'
	lbu	$t1, ($i)		# symbol pointed by iterator
	li	$t2, 1			# decimal after-point digits number
	li	$t3, %dapi		# for shift iterating
	li	$t4, ZERPONE		# for dividing into 10
	bne	$t1, '-', nminus_frac_read
	li	$t0, 1			# number sign: 0 - '+', 1 - '-'
	addiu	$i, $i, 1
	j	point_ignore_frac_read
nminus_frac_read:
	bne	$t1, '+', point_ignore_frac_read
	addiu	$i, $i, 1
point_ignore_frac_read:
	lbu	$t1, ($i)
	bne	$t1, '0', non_zero_frac_read
	addiu	$i, $i, 1
	j pos_frac_read
non_zero_frac_read:
	bne	$t1, '1', begin_convert_frac_read
	li	$d, 1
	sll	$d, $d, %dapi
	addiu	$i, $i, 1
	j pos_frac_read
begin_convert_frac_read:
	addiu	$i, $i, 1
	lbu	$t1, ($i)
convert_frac_read:
	subiu	$t1, $t1, '0'
	addu	$d, $d, $t1
	addiu	$i, $i, 1
	lbu	$t1, ($i)		# new symbol
	blt	$t1, '0', norm_frac_read
	bgt	$t1, '9', norm_frac_read
	addiu	$t2, $t2, 1
	mulu	$d, $d, 10
	j	convert_frac_read
norm_frac_read:
	beqz	$t3, div10_frac_read	# if not notmalized yet
	andi	$t1, $d, 0x40000000	# is 2. leftmost bit (1. nonsign bit) equal to 1?
	bnez	$t1, div10_frac_read	# if not max leftshifted
	sll	$d, $d, 1
	addiu	$t3, $t3, -1
	j	norm_frac_read
div10_frac_read:
	beqz	$t2, neg_frac_read
	multu	$d, $t4
	mfhi	$d
	addiu	$t2, $t2, -1
	j	norm_frac_read
neg_frac_read:
	beqz	$t0, pos_frac_read	# if negative
	negu	$d, $d
pos_frac_read:
	.end_macro
	
	# multiplies fixed-point numbers with %dapi digits after the point and $dbpi before the point: $d = $m1 * $m2
	.macro	fixp_mult($d, $m1, $m2, %dapi, %dbpi)
	mult	$m1, $m2
	mfhi	$d
	mflo	$t0
	sll	$d, $d, %dbpi
	srl	$t0, $t0, %dapi
	or	$d, $d, $t0
	.end_macro
	
	# divides fixed-point numbers with %dapi digits after the point: $d = $dvd / $div
	.macro	fixp_div($d, $dvd, $div, %dapi)
	li	$t0, %dapi			# digits after point number iterator
	move	$d, $dvd
	move	$t1, $div
shdvd_fixp_div:
	beqz	$t0, dv_fixp_div		# if denormalizing not completed
	andi	$t2, $d, 0x80000000		# leftmost bit of dividend
	andi	$t3, $d, 0x40000000		# second leftmost bit of dividend
	xor	$t2, $t2, $t3
	bnez	$t2, shdiv_fixp_div		# if dividend may still be shifted
	sll	$d, $d, 1
	addiu	$t0, $t0, -1
	j shdvd_fixp_div
shdiv_fixp_div:
	srav	$t1, $t1, $t0
dv_fixp_div:
	div	$d, $d, $t1
	.end_macro
	
	# multiplies matrixes: %dl[%mi x %pi] = %m1l[%mi x %ni] * %m2l[%ni x %pi]. %dl cannot be %m1l or %m2l; matrixes contain fixed-point numbers with %dapi digits after the point and $dbpi before the point; %npi should be %ni*%pi, %mpi should be %mi*%pi
	.macro	mx_mult(%dl, %m1l, %m2l, %mi, %ni, %pi, %npi, %mpi, %dapi, %dbpi)
	la	$t1, %m1l			# m1 iterator
	la	$t2, %m2l			# m2 iterator
	la	$t3, %dl			# d iterator
	li	$a0, %pi			# m2's row length
	sll	$a0, $a0, 2			# x4 (so that it was in bytes)
	li	$a1, %npi			# m2's column length
	sll	$a1, $a1, 2			# x4 (so that it was in bytes)
	li	$a2, %ni			# m1's row length
	sll	$a2, $a2, 2			# x4 (so that it was in bytes)
	addu	$t8, $t2, $a1			# element after the last cell of m2
	addiu	$t8, $t8, -4
	addu	$t8, $t8, $a0			# ... now vertically (i.e. +1 row)
	li	$t9, %mpi			# result matrix size
	sll	$t9, $t9, 2			# x4 (so that it was in bytes)
	addu	$t9, $t9, $t3			# element after the last cell of d
new_cell_mx_mult:
	li	$t4, 0				# value being computed for the current cell
	li	$t7, 0				# n counter
n_mx_mult:					# calculating current cell
	lw	$t5, ($t1)
	lw	$t6, ($t2)
	fixp_mult($t5, $t5, $t6, %dapi, %dbpi)
	addu	$t4, $t4, $t5
	addiu	$t1, $t1, 4
	addu	$t2, $t2, $a0
	addiu	$t7, $t7, 1
	bne	$t7, %ni, n_mx_mult
	sw	$t4, ($t3)			# saving calculated cell
	addiu	$t3, $t3, 4			# next resulting cell
	beq	$t2, $t8, m2end_mx_mult		# if not end of the row
	subu	$t2, $t2, $a1
	addiu	$t2, $t2, 4
	subu	$t1, $t1, $a2
	j 	new_cell_mx_mult
m2end_mx_mult:
	la	$t2, %m2l
	bne	$t3, $t9, new_cell_mx_mult	# no more resulting cells
	.end_macro
	
	# draws line of %thcki pix thickness and %lci color connecting vertexes ($x1, $y1) and ($x2, $y2) of %vci color on the bitmap %bmpl[%wi x %hi]
	.macro	drln(%bmpl, %wi, %hi, $x1, $y1, $x2, $y2, %thcki, %lci, %vci)	# Bresenham
	# prolog
	addiu	$sp, $sp, -36
	sw	$s0, ($sp)
	sw	$s1, 4($sp)
	sw	$s2, 8($sp)
	sw	$s3, 12($sp)
	sw	$s4, 16($sp)
	sw	$s5, 20($sp)
	sw	$s6, 24($sp)
	sw	$s7, 28($sp)
	sw	$fp, 32($sp)
	move	$t0, $x1
	move	$t1, $y1
	move	$t2, $x2
	move	$t3, $y2
	move	$s5, $t0			# x1
	move	$s6, $t1			# y1
	move	$s7, $t2			# x2
	move	$fp, $t3			# y2
	# body
	li	$t8, %thcki
	li	$t9, %thcki
	srl	$t9, $t9, 1			# upper (visually lower) thickness shifting (shifts to the first pixel to be painted)
	subu	$t8, $t8, $t9			# lower (visually upper) thickness shifting (shifts to pixel after the last to be painted)
	li	$a0, %wi
	mulu	$a0, $a0, %hi
	addu	$a2, $a0, $a0
	addu	$a0, $a2, $a0			# mulu	$a0, 3
	la	$s4, %bmpl			# first pixel of the bitmap
	addu	$a0, $a0, $s4			# byte after the last pixel of the bitmap
	mul	$t3, $s6, %wi
	addu	$t3, $t3, $s5
	addu	$a2, $t3, $t3
	addu	$t3, $a2, $t3			# mul	$t3, $t3, 3
	addu	$t2, $s4, $t3			# pixel iterator
	move	$s3, $t2			# (x1, y1)
	li	$t4, -1				# independent variable (x or y) relative iterator
	li	$t5, 1				# change-dependent-variable border (fixed-point number 1; currently there is 0 digits after point)
	subu	$t0, $s7, $s5			# $t0 = x2-x1
	subu	$t1, $fp, $s6			# $t1 = y2-y1
	abs	$t0, $t0			# $t0 = |x2-x1|
	abs	$t1, $t1			# $t1 = |y2-y1|
	bltu	$t0, $t1, xlty			# if |x2-x1| >= |y2-y1|
	# adjusting drawing func y = y(x)
	beqz	$t0, begin_draw_vtx1		# if |x2-x1| != 0 (i.e. if |x2-x1| == 0 => |y2-y1| == 0 as well => draw only vertexes)
	beqz	$t1, def_step_yx		# if |y2-y1| != 0 (otherwise don't shift err point)
shift_point_yx:					# shifting left point to gain maximal precision
	sll	$t1, $t1, 1
	sll	$t5, $t5, 1
	andi	$t3, $t1, 0x80000000
	beqz	$t3, shift_point_yx
def_step_yx:
	move	$t3, $t0			# defining max_value of $t4 independent variable (x) relative iterator
	divu	$t0, $t1, $t0			# defining permanent step for y(x): $t0 = |(y2-y1)/(x2-x1)|; fixed-point 1 is stored in $t5
	srl	$t7, $t5, 1			# defining half of fixed-point 1 for permanent step: $t7 = $t5/2
	li	$t6, 3				# defining discrete step for x: $t6 = 3
	bgt	$s7, $s5, def_y_step_yx		# if x2<x1
	li	$t6, -3				# defining discrete step for x: $t6 = -3
def_y_step_yx:
	li	$t1, %wi
	addu	$a2, $t1, $t1
	addu	$t1, $a2, $t1			# mulu	$t1, $t1, 3; defining discrete step for y(x): $t1 = row_length
	move	$a1, $t1			# positive discrete step for y(x): $a1 = |$t1|
	mulu	$t8, $t8, $t1			# precising thickness shifting
	mulu	$t9, $t9, $t1			# precising thickness shifting
	bge	$fp, $s6, begin_draw		# if y2<y1
	negu	$t1, $t1			# defining discrete step for y(x): $t1 = -row_length
	j	begin_draw
xlty:						# if |x2-x1| < |y2-y1|
	beqz	$t0, def_step_xy		# if |x2-x1| != 0 (otherwise don't shift err point)
shift_point_xy:					# shifting left point to gain maximal precision
	sll	$t0, $t0, 1
	sll	$t5, $t5, 1
	andi	$t3, $t0, 0x80000000
	beqz	$t3, shift_point_xy
def_step_xy:
	move	$t3, $t1			# defining max_value of $t4 independent variable (y) relative iterator
	divu	$t0, $t0, $t1			# defining permanent step for y(x): $t0 = |(x2-x1)/(y2-y1)|; fixed-point 1 is stored in $t5
	srl	$t7, $t5, 1			# defining half of fixed-point 1 for permanent step: $t7 = $t5/2
	li	$t6, %wi
	addu	$a2, $t6, $t6
	addu	$t6, $a2, $t6			# defining discrete step for y: $t6 = row_length
	bgt	$fp, $s6, def_x_step_xy		# if y2<y1
	negu	$t6, $t6			# defining discrete step for x: $t6 = -row_length
def_x_step_xy:
	li	$t1, 3				# defining discrete step for x(y): $t1 = 3
	move	$a1, $t1			# positive discrete step for x(y): $a1 = |$t1|
	addu	$a2, $t8, $t8
	addu	$t8, $a2, $t8			# precising thickness shifting
	addu	$a2, $t9, $t9
	addu	$t9, $a2, $t9			# precising thickness shifting
	bge	$s7, $s5, begin_draw		# if x2<x1
	li	$t1, -3				# defining discrete step for x(y): $t1 = -3
begin_draw:
	li	$s0, %lci
	li	$s1, %lci
	li	$s2, %lci
	andi	$s0, $s0, 0xFF			# blue line color component
	andi	$s1, $s1, 0xFF00		# green line color component
	srl	$s1, $s1, 8
	andi	$s2, $s2, 0xFF0000		# red line color component
	srl	$s2, $s2, 16
	li	$s5, %vci
	li	$s6, %vci
	li	$s7, %vci
	andi	$s5, $s5, 0xFF			# blue vertex color component
	andi	$s6, $s6, 0xFF00		# green vertex color component
	srl	$s6, $s6, 8
	andi	$s7, $s7, 0xFF0000		# red vertex color component
	srl	$s7, $s7, 16
	subu	$t2, $t2, $t6
	negu	$v0, $t0			# defining error iterator (now -permanent_step)
	li	$v1, 0				# bool whether err >= 0.5 and dependent variable descrete step has already been committed
nxt_indp_var:
	addiu	$t4, $t4, 1			# independent_var_rel_iter++
	bgtu	$t4, $t3, epilog
	addu	$t2, $t2, $t6			# independent_var++
	addu	$v0, $v0, $t0
	bnez	$v1, nonewstep			# if dependent variable descrete step has not already been committed
	bleu	$v0, $t7, err_novf		# if err > 0.5
	addu	$t2, $t2, $t1
	li	$v1, 1
nonewstep:
	bltu	$v0, $t5, err_novf		# if err >= 1
	subu	$v0, $v0, $t5
	li	$v1, 0
err_novf:
	subu	$a2, $t2, $t9			# starting (upper, visually lower) pixel to paint a current point (of line thickness %thck); thickness iterator
	addu	$a3, $t2, $t8			# pixel after the last (lower, visually upper) to paint a current point (of line thickness %thck)
	subu	$a2, $a2, $a1
paint_nxt_thck_pix:
	addu	$a2, $a2, $a1
	beq	$a2, $a3, nxt_indp_var
	blt	$a2, $s4, paint_nxt_thck_pix
	bge	$a2, $a0, paint_nxt_thck_pix
	lb	$fp, ($a2)
	bnez	$fp, no_color
	lb	$fp, 1($a2)
	bnez	$fp, no_color
	lb	$fp, 2($a2)
	bnez	$fp, no_color
	sb	$s0, ($a2)
	sb	$s1, 1($a2)
	sb	$s2, 2($a2)
	j	paint_nxt_thck_pix
no_color:
	sb	$s5, ($a2)
	sb	$s6, 1($a2)
	sb	$s7, 2($a2)
	j	paint_nxt_thck_pix
begin_draw_vtx1:
	li	$s0, %vci
	li	$s1, %vci
	li	$s2, %vci
	andi	$s0, $s0, 0xFF			# blue vertex color component
	andi	$s1, $s1, 0xFF00		# green vertex color component
	srl	$s1, $s1, 8
	andi	$s2, $s2, 0xFF0000		# red vertex color component
	srl	$s2, $s2, 16
	li	$t3, %wi
	addiu	$t3, $t3, 1
	addu	$t4, $t3, $t3
	addu	$t3, $t4, $t3			# $t3 = 3(%wi + 1)
	li	$t1, %thcki
	addu	$t5, $t1, $t1
	addu	$t5, $t5, $t1			# $t5 = 3%thck
	srl	$t0, $t1, 1
	subu	$t1, $t1, $t0
	addiu	$t1, $t1, -1
	mulu	$t0, $t0, $t3			# shift to upper-left vertex corner relative to its center: $t0 = 3(%thck/2)(%wi+1)
	mulu	$t1, $t1, $t3			# shift to lower-right vertex corner relative to its center: $t1 = 3(%thck - (%thck/2) - 1)(%wi+1)
	subu	$t3, $t3, $t5			# vertex newline shift: $t3 = 3(%wi + 1 - %thck)
	addiu	$t3, $t3, -3			# vertex newline shift - 1 pixel: $t3 = 3(%wi - %thck)
	# drawing vertex (x1,y1)
	addu	$t4, $s3, $t1			# lower-right vertex (x1, y1) corner
	subu	$s3, $s3, $t0			# upper-left vertex (x1, y1) corner
	li	$t5, 0				# x iterator
draw_vtx1:
	blt	$s3, $s4, outofrange_vtx1
	bge	$s3, $a0, outofrange_vtx1
	sb	$s0, ($s3)
	sb	$s1, 1($s3)
	sb	$s2, 2($s3)
outofrange_vtx1:
	beq	$s3, $t4, begin_draw_vtx2
	addiu	$t5, $t5, 1
	addiu	$s3, $s3, 3
	bne	$t5, %thcki, draw_vtx1
	addu	$s3, $s3, $t3
	li	$t5, 0
	j	draw_vtx1
begin_draw_vtx2:
	addu	$t4, $t2, $t1			# lower-right vertex (x2, y2) corner
	subu	$t2, $t2, $t0			# upper-left vertex (x2, y2) corner
	li	$t5, 0				# x iterator
draw_vtx2:
	blt	$t2, $s4, outofrange_vtx2
	bge	$t2, $a0, outofrange_vtx2
	sb	$s0, ($t2)
	sb	$s1, 1($t2)
	sb	$s2, 2($t2)
outofrange_vtx2:
	beq	$t2, $t4, epilog
	addiu	$t5, $t5, 1
	addiu	$t2, $t2, 3
	bne	$t5, %thcki, draw_vtx2
	addu	$t2, $t2, $t3
	li	$t5, 0
	j	draw_vtx2
epilog:
	lw	$s0, ($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s3, 12($sp)
	lw	$s4, 16($sp)
	lw	$s5, 20($sp)
	lw	$s6, 24($sp)
	lw	$s7, 28($sp)
	lw	$fp, 32($sp)
	addiu	$sp, $sp, 36
	.end_macro
	.macro round($d, $s, %dapi, %maski)
	andi	$t1, $s, %maski
	sra	$d, $s, %dapi
	beqz	$t1, end_round
	addiu	$d, $d, 1
end_round:
	.end_macro