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
	;prologue
	enter	4, 0
	;body
	movupd	xmm0, [ebp+12]				; loading p.x, p.y
	movapd	[mainvect], xmm0
	movupd	xmm0, [ebp+28]				; loading p.z, cosfix
	movlpd	[mainvect+16], xmm0
	movhpd	[rm1_col1+8], xmm0
	movhpd	[rm1_col2+16], xmm0
	movupd	xmm0, [ebp+44]				; loading sinfix, cosfiy
	movlpd	[rm1_col2+8], xmm0
	movhpd	[rm2_col0], xmm0
	movhpd	[rm2_col2+16], xmm0
	xorpd	xmm0, [dnegmask]			; -sinfix
	movlpd	[rm1_col1+16], xmm0
	movupd	xmm0, [ebp+60]				; loading sinfiy, cosfiz
	movlpd	[rm2_col0+16], xmm0
	movhpd	[rm3_col0], xmm0
	movhpd	[rm3_col1+8], xmm0
	xorpd	xmm0, [dnegmask]			; -sinfiy
	movlpd	[rm2_col2], xmm0
	movlpd	xmm0, [ebp+76]				; loading sinfiz
	movlpd	[rm3_col1], xmm0
	xorpd	xmm0, [dnegmask]			; -sinfiz
	movlpd	[rm3_col0+8], xmm0
	lea		eax, [rm1_col0]
	mov		[ebp-4], eax
	call	mxmult
	lea		eax, [rm2_col0]
	mov		[ebp-4], eax
	call	mxmult
	lea		eax, [rm3_col0]
	mov		[ebp-4], eax
	call	mxmult
	movapd	xmm0, [mainvect]
	movapd	xmm1, [mainvect + 16]
	unpckhpd	xmm2, xmm1
	unpckhpd	xmm2, xmm2
	divpd	xmm0, xmm2
	divpd	xmm1, xmm2
	;saving result & epilogue
	leave
	pop		eax
	xchg	eax, [esp]
	movupd	[eax], xmm0
	movlpd	[eax+16], xmm1
	movapd	[mainvect+16], xmm1
	ret

;DPoint move_project(DPoint p, double Tx, double Ty, double Tz, double camx, double camy, double camdis)
move_project:
	;prologue
	enter	4, 0
	;body
	movupd	xmm0, [ebp+12]				; loading p.x, p.y
	movapd	[mainvect], xmm0
	movupd	xmm0, [ebp+28]				; loading p.z, Tx
	movlpd	[mainvect+16], xmm0
	movapd	xmm7, xmm0
	movupd	xmm1, [ebp+44]				; loading Ty, Tz
	shufpd	xmm0, xmm1, 1
	movupd	xmm2, [ebp+60]				; loading camx, camy
	subpd	xmm0, xmm2
	movlpd	[mm3_col0+24], xmm2
	movhpd	[mm3_col1+24], xmm2
	movlpd	[mm1_col0+24], xmm0
	movhpd	[mm1_col1+24], xmm0
	movhpd	xmm0, [ebp+76]				; loading camdis
	addpd	xmm1, xmm0
	movhpd	[mm1_col2+24], xmm1
	movhpd	xmm1, [mm1_col0]			; loading 1
	divpd	xmm1, xmm0
	movhpd	[mm2_col3+16], xmm1
	xorpd	xmm0, [dnegmask]			; -camdis
	movhpd	[mm3_col2+24], xmm0
	lea		eax, [mm1_col0]
	mov		[ebp-4], eax
	call	mxmult
	lea		eax, [mm2_col0]
	mov		[ebp-4], eax
	call	mxmult
	lea		eax, [mm3_col0]
	mov		[ebp-4], eax
	call	mxmult
	movapd	xmm0, [mainvect]
	movapd	xmm1, [mainvect + 16]
	unpckhpd	xmm1, xmm1
	divpd	xmm0, xmm1
	;saving result & epilogue
	leave
	pop		eax
	xchg	eax, [esp]
	movupd	[eax], xmm0
	movlpd	[eax+16], xmm7
	mov		DWORD[mainvect+24], 0
	mov		DWORD[mainvect+28], 0x3FF00000
	ret

;multiplies matrixes 1x4 (written under mainvect label) and 4x4 (written by columns under address matrix*) and saves result into mainvect
;void mxmult(matrix*)
mxmult:
	;prologue
	enter	0, 0
	;body
	mov		eax, [ebp+8]
	movapd	xmm0, [mainvect]
	movapd	xmm1, [mainvect+16]
	movapd	xmm2, [eax]
	movapd	xmm3, [eax+16]
	mulpd	xmm2, xmm0
	mulpd	xmm3, xmm1
	addpd	xmm2, xmm3
	movapd	xmm3, [eax+32]
	movapd	xmm4, [eax+48]
	mulpd	xmm3, xmm0
	mulpd	xmm4, xmm1
	addpd	xmm3, xmm4
	haddpd	xmm2, xmm3
	movapd	xmm5, [eax+64]
	movapd	xmm3, [eax+80]
	mulpd	xmm5, xmm0
	mulpd	xmm3, xmm1
	addpd	xmm5, xmm3
	movapd	xmm3, [eax+96]
	movapd	xmm4, [eax+112]
	mulpd	xmm3, xmm0
	mulpd	xmm4, xmm1
	addpd	xmm3, xmm4
	haddpd	xmm5, xmm3
	movapd	[mainvect], xmm2
	movapd	[mainvect+16], xmm5
	;epilogue
	leave
	ret
;void sort_lines(Line* lines[12])
sort_lines:
	;prologue
	enter	0, 0
	push	ebx
	push	edi
	;body
	mov		eax, [ebp+8]			;0
	mov		ecx, eax
	add		ecx, 48					;i
ext_loop:
	sub		ecx, 4
	cmp		ecx, eax				; if(i==0)
	je		epilogue
	mov		edx, eax				;j
	mov		ebx, [eax]
	movsd	xmm0, [ebx+16]			;lines[0]->p1.z
	movsd	xmm1, [ebx+40]			;lines[0]->p2.z
int_loop:
	cmp		edx, ecx				;if(j==i)
	je		ext_loop
	add		edx, 4
	mov		edi, [edx]
	movsd	xmm2, [edi+16]			;lines[j+1]->p1.z
	comisd	xmm0, xmm2				;if(lines[j]->p1.z < lines[j+1]->p1.z)
	jb		exchange
	comisd	xmm1, xmm2				;if(lines[j]->p2.z < lines[j+1]->p1.z)
	jb		exchange
	movsd	xmm0, xmm2
	movsd	xmm1, [edi+40]
	mov		ebx, edi
	jmp		int_loop
exchange:
	mov		[edx-4], edi
	mov		[edx], ebx
	jmp		int_loop
epilogue:
	pop		edi
	pop		ebx
	leave
	ret
