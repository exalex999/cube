global rotate
global move_project
global sort_lines

section .data
align 16
dnegmask:	dq 0x8000000000000000, 0x8000000000000000
mainvect:	dq 0.0, 0.0, 0.0, 1.0
rm1_col0:	dq 1.0, 0.0, 0.0, 0.0
rm1_col1:	dq 0.0, 0.0, 0.0, 0.0
rm1_col2:	dq 0.0, 0.0, 0.0, 0.0
rm1_col3:	dq 0.0, 0.0, 0.0, 1.0
rm2_col0:	dq 0.0, 0.0, 0.0, 0.0
rm2_col1:	dq 0.0, 1.0, 0.0, 0.0
rm2_col2:	dq 0.0, 0.0, 0.0, 0.0
rm2_col3:	dq 0.0, 0.0, 0.0, 1.0
rm3_col0:	dq 0.0, 0.0, 0.0, 0.0
rm3_col1:	dq 0.0, 0.0, 0.0, 0.0
rm3_col2:	dq 0.0, 0.0, 1.0, 0.0
rm3_col3:	dq 0.0, 0.0, 0.0, 1.0
mm1_col0:	dq 1.0, 0.0, 0.0, 0.0
mm1_col1:	dq 0.0, 1.0, 0.0, 0.0
mm1_col2:	dq 0.0, 0.0, 1.0, 0.0
mm1_col3:	dq 0.0, 0.0, 0.0, 1.0
mm2_col0:	dq 1.0, 0.0, 0.0, 0.0
mm2_col1:	dq 0.0, 1.0, 0.0, 0.0
mm2_col2:	dq 0.0, 0.0, 1.0, 0.0
mm2_col3:	dq 0.0, 0.0, 0.0, 0.0
mm3_col0:	dq 1.0, 0.0, 0.0, 0.0
mm3_col1:	dq 0.0, 1.0, 0.0, 0.0
mm3_col2:	dq 0.0, 0.0, 1.0, 0.0
mm3_col3:	dq 0.0, 0.0, 0.0, 1.0

section	.text

;DPoint rotate(DPoint p, double cosfix, double sinfix, double cosfiy, double sinfiy, double cosfiz, double sinfiz)
rotate:
	movapd	xmm7, [rsp+8]
	movlpd	xmm8, [rsp+24]
	movapd	[mainvect], xmm7
	movlpd	[mainvect+16], xmm8
	movlpd	[rm1_col1+8], xmm0
	movlpd	[rm1_col2+16], xmm0
	movlpd	[rm1_col2+8], xmm1
	xorpd	xmm1, [dnegmask]
	movlpd	[rm1_col1+16], xmm1
	movlpd	[rm2_col0], xmm2
	movlpd	[rm2_col2+16], xmm2
	movlpd	[rm2_col0+16], xmm3
	xorpd	xmm3, [dnegmask]
	movlpd	[rm2_col2], xmm3
	movlpd	[rm3_col0], xmm4
	movlpd	[rm3_col1+8], xmm4
	movlpd	[rm3_col1], xmm5
	xorpd	xmm5, [dnegmask]
	movlpd	[rm3_col0+8], xmm5
	mov		rax, rdi
	lea		rdi, [rm1_col0]
	call	mxmult
	lea		rdi, [rm2_col0]
	call	mxmult
	lea		rdi, [rm3_col0]
	call	mxmult
	movapd	xmm0, [mainvect]
	movapd	xmm1, [mainvect + 16]
	unpckhpd	xmm2, xmm1
	unpckhpd	xmm2, xmm2
	divpd	xmm0, xmm2
	divpd	xmm1, xmm2
	movupd	[rax], xmm0
	movlpd	[rax+16], xmm1
	movapd	[mainvect+16], xmm1
	ret

;DPoint move_project(DPoint p, double Tx, double Ty, double Tz, double camx, double camy, double camdis)
move_project:
	subpd	xmm0, xmm3
	subpd	xmm1, xmm4
	addpd	xmm2, xmm5
	movlpd	xmm6, [mm1_col0]
	divpd	xmm6, xmm5
	xorpd	xmm5, [dnegmask]
	movapd	xmm7, [rsp+8]
	movlpd	xmm8, [rsp+24]
	movapd	[mainvect], xmm7
	movlpd	[mainvect+16], xmm8
	movlpd	[mm1_col0+24], xmm0
	movlpd	[mm1_col1+24], xmm1
	movlpd	[mm1_col2+24], xmm2
	movlpd	[mm2_col3+16], xmm6
	movlpd	[mm3_col0+24], xmm3
	movlpd	[mm3_col1+24], xmm4
	movlpd	[mm3_col2+24], xmm5
	mov		rax, rdi
	lea		rdi, [mm1_col0]
	call	mxmult
	lea		rdi, [mm2_col0]
	call	mxmult
	lea		rdi, [mm3_col0]
	call	mxmult
	movapd	xmm0, [mainvect]
	movapd	xmm1, [mainvect + 16]
	unpckhpd	xmm1, xmm1
	divpd	xmm0, xmm1
	movupd	[rax], xmm0
	movlpd	[rax+16], xmm8
	mov		DWORD[mainvect+24], 0
	mov		DWORD[mainvect+28], 0x3FF00000
	ret

;multiplies matrixes 1x4 (written under mainvect label) and 4x4 (written by columns under address matrix*) and saves result into mainvect
;void mxmult(matrix*)
mxmult:
	movapd	xmm0, [mainvect]
	movapd	xmm1, [mainvect+16]
	movapd	xmm2, [rdi]
	movapd	xmm3, [rdi+16]
	mulpd	xmm2, xmm0
	mulpd	xmm3, xmm1
	addpd	xmm2, xmm3
	movapd	xmm3, [rdi+32]
	movapd	xmm4, [rdi+48]
	mulpd	xmm3, xmm0
	mulpd	xmm4, xmm1
	addpd	xmm3, xmm4
	haddpd	xmm2, xmm3
	movapd	xmm5, [rdi+64]
	movapd	xmm3, [rdi+80]
	mulpd	xmm5, xmm0
	mulpd	xmm3, xmm1
	addpd	xmm5, xmm3
	movapd	xmm3, [rdi+96]
	movapd	xmm4, [rdi+112]
	mulpd	xmm3, xmm0
	mulpd	xmm4, xmm1
	addpd	xmm3, xmm4
	haddpd	xmm5, xmm3
	movapd	[mainvect], xmm2
	movapd	[mainvect+16], xmm5
	ret
;void sort_lines(Line* lines[12])
sort_lines:
	mov		rcx, rdi
	add		rcx, 96					;i
ext_loop:
	sub		rcx, 8
	cmp		rcx, rdi				; if(i==0)
	je		epilogue
	mov		rdx, rdi				;j
	mov		rsi, [rdi]
	movsd	xmm0, [rsi+16]			;lines[0]->p1.z
	movsd	xmm1, [rsi+40]			;lines[0]->p2.z
int_loop:
	cmp		rdx, rcx				;if(j==i)
	je		ext_loop
	add		rdx, 8
	mov		rax, [rdx]
	movsd	xmm2, [rax+16]			;lines[j+1]->p1.z
	comisd	xmm0, xmm2				;if(lines[j]->p1.z < lines[j+1]->p1.z)
	jb		exchange
	comisd	xmm1, xmm2				;if(lines[j]->p2.z < lines[j+1]->p1.z)
	jb		exchange
	movsd	xmm0, xmm2
	movsd	xmm1, [rax+40]
	mov		rsi, rax
	jmp		int_loop
exchange:
	mov		[rdx-8], rax
	mov		[rdx], rsi
	jmp		int_loop
epilogue:
	ret
