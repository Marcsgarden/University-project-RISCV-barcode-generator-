.eqv	bitmap_len	90000
.eqv	buffer_len	128
.eqv	header_len	54
.eqv	sym_start	12548
.eqv	sym_stop	16548
.eqv	bar_height	30
.eqv	bar_width	2
.data
strlen:		.word	0
buffer:		.space	buffer_len
bitmap: 	.space 	bitmap_len
header: 	.byte 	66, 77, 200, 95, 1, 0, 0, 0, 0, 0, 54, 0, 0, 0, 40, 0, 0, 0, 88, 2, 0, 0, 50, 0, 0, 0, 1, 0, 24, 0, 0, 0, 0, 0, 146, 95, 1, 0, 18, 11, 0, 0, 18, 11, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
str_promt:	.asciz	"Input> "
str_file:	.asciz	"barcode.bmp"
.text
main:
	# ask for input
	li		a7, 4
	la		a0, str_promt
	ecall
	# read input
	li		a7, 8
	la		a0, buffer
	li		a1, buffer_len
	ecall
	# measure strlen
	add		a1, a1, a0
strlen_loop:
	lbu		t0, (a0)
	beqz	t0, strlen_done
	addi	a0, a0, 1
	blt		a0, a1, strlen_loop
strlen_done:
	addi	a0, a0, -1
	la		t0, buffer
	sub		t1, a0, t0
	la		t0, strlen
	sw		t1, 0(t0)
	# clear the bitmap surface
bitmap_clear:
	la		t0, bitmap
	li		t1, bitmap_len
	li		t2, 0xFF
	add		t1, t1, t0
bitmap_clear_loop:
	sb		t2, 0(t0)
	addi	t0, t0, 1
	bne		t0, t1, bitmap_clear_loop
	call	draw_string
bitmap_save:
	li		a7, 1024
	la		a0, str_file
	li		a1, 1
	ecall
	mv		s0, a0
	li		a7, 64
	la		a1, header
	li		a2, header_len
	ecall
	mv		a0, s0
	la		a1, bitmap
	li		a2, bitmap_len
	ecall
	mv		a0, s0
	li		a7, 57
	ecall	
exit:
	li		a7, 10
	ecall
#####
.data
.eqv	stride		1800
.eqv	pixel		3
pos_x:		.word	300
pos_y:		.word	25
.text
.eqv	rect_x	s0
.eqv	rect_x0	s1
.eqv	rect_y0	s2
.eqv	rect_x1	s3
.eqv	rect_y1	s4
# void draw_rect(int x0, int y0, int x1, int y1)
draw_rect:
	addi	sp, sp, -24
	sw		ra, 0(sp)
	sw		rect_x, 4(sp)
	sw		rect_x0, 8(sp)
	sw		rect_y0, 12(sp)
	sw		rect_x1, 16(sp)
	sw		rect_y1, 20(sp)	
	mv		rect_x0, a0
	mv		rect_y0, a1
	mv		rect_x1, a2
	mv		rect_y1, a3
draw_for_y:
	mv		rect_x, rect_x0
draw_for_x:
	la		t0, bitmap
	li		t1, stride
	mul		t1, t1, rect_y0
	add		t0, t0, t1
	li		t1, pixel
	mul		t1, t1, rect_x
	add		t0, t0, t1
	sb		zero, 0(t0)
	sb		zero, 1(t0)
	sb		zero, 2(t0)
	addi	rect_x, rect_x, 1
	blt		rect_x, rect_x1, draw_for_x
	addi	rect_y0, rect_y0, 1
	blt		rect_y0, rect_y1, draw_for_y
	lw		ra, 0(sp)
	lw		rect_x, 4(sp)
	lw		rect_x0, 8(sp)
	lw		rect_y0, 12(sp)
	lw		rect_x1, 16(sp)
	lw		rect_y1, 20(sp)
	addi	sp, sp, 24
	ret
#####
#####
.data
.eqv	bounds_def	6
.eqv	bounds_ext	7
.text
.eqv	sym_symbol	s0
.eqv	sym_bounds	s1
.eqv	sym_width	s2
.eqv	sym_step	s3
draw_symbol:
	addi	sp, sp, -20
	sw		ra, 0(sp)
	sw		s0, 4(sp)
	sw		s1, 8,(sp)
	sw		s2, 12(sp)
	sw		s3, 16(sp)
	mv		sym_step, zero
	mv		sym_symbol, a0
	li		sym_bounds, bounds_def
	li		t0, sym_stop
	bne		sym_symbol, t0, draw_symbol_loop
	li		sym_bounds, bounds_ext
draw_symbol_loop:
	srli	sym_symbol, sym_symbol, 2
	andi	sym_width, sym_symbol, 3
	addi	sym_width, sym_width, 1
	li		t0, bar_width
	mul		sym_width, sym_width, t0
	andi	t0, sym_step, 1
	bnez	t0, draw_symbol_skip
	la		t0, pos_x
	lw		a0, (t0)
	la		t0, pos_y
	lw		a1, (t0)
	add		a2, a0, sym_width
	addi	a3, a1, bar_height
	call	draw_rect
draw_symbol_skip:
	la		t0, pos_x
	lw		a0, (t0)
	add		a0, a0, sym_width
	sw		a0, (t0)
	addi	sym_step, sym_step, +1
	blt		sym_step, sym_bounds, draw_symbol_loop
draw_symbol_done:
	lw		ra, 0(sp)
	lw		s0, 4(sp)
	lw		s1, 8(sp)
	lw		s2, 12(sp)
	lw		s3, 16(sp)
	addi	sp, sp, +20
	ret
#####
.data
.text
.eqv	str_checksum	s0
.eqv	str_index		s1
draw_string:
	addi	sp, sp, -12
	sw		ra, 0(sp)
	sw		s0, 4(sp)
	sw		s1, 8,(sp)
	#
	li		str_checksum, 104
	# str_checksum = 1023
	la		t0, strlen
	lw		a0, (t0)
	li		t0, 11
	mul		a0, a0, t0
	li		t0, bar_width
	mul		a0, a0, t0
	li		t1, 35
	mul		t1, t1, t0
	add		a0, a0, t1
	srli	a0, a0, 1
	la		t0, pos_x
	lw		t1, (t0)
	sub		a0, t1, a0
	sw		a0, (t0)
	# pos_x = 300 - ((bar_width * 35 + bar_width * 11 * strlen) >> 1)	
	la		t0, pos_y
	lw		a0, (t0)
	li		t1, bar_height
	srli	t1, t1, 1
	sub		a0, a0, t1
	sw		a0, (t0)
	# pos_y = 25 - (bar_height >> 1)
	li		a0, sym_start
	call	draw_symbol		# draw_symbol(sym_start)
	# str_index = 0
	mv		str_index, zero
draw_string_loop:
	la		t0, buffer
	add		t0, t0, str_index
	lbu		a0, (t0)
	call	index_of_symbol
	call	load_symbol
	call	draw_symbol
	lw		t0, strlen
	addi	str_index, str_index, 1
	blt		str_index, t0, draw_string_loop
draw_string_done:
	mv		a0, str_checksum
	li		t0, 103
	rem		a0, a0, t0		# checksum %= 103
	call	load_symbol
	call	draw_symbol		# draw_symbol(load_symbol(index_of_symbol(checksum)))
	li		a0, sym_stop
	call	draw_symbol		# draw_symbol(sym_stop)
	#
	lw		ra, 0(sp)
	lw		s0, 4(sp)
	lw		s1, 8,(sp)
	addi	sp, sp, +12
	ret
draw_string_error_symbol:
	j		draw_string_done
#####
.data
indices:	.half	5444, 5204, 1364, 9488, 5648, 5408, 8528, 4688, 4448, 8468, 4628, 4388, 6464, 6224, 2384, 5504, 5264, 1424, 404, 6164, 2324, 4484, 4244, 2120, 5384, 5144, 1304, 4424, 4184, 344, 9284, 1604, 1124, 9728, 9248, 1568, 8768, 8288, 608, 8708, 8228, 548, 10304, 2624, 2144, 9344, 1664, 1184, 1160, 2564, 2084, 8324, 644, 2180, 9224, 1544, 1064, 8264, 584, 104, 200, 788, 44, 13568, 5888, 13328, 1808, 5168, 1328, 12608, 4928, 12368, 848, 4208, 368, 308, 12308, 140, 4148, 224, 7424, 7184, 3344, 4544, 4304, 464, 4364, 4124, 284, 3140, 1220, 1100, 11264, 3584, 3104, 8384, 704, 8204, 524, 3200, 2240, 3080, 2060, 4868, 12548, 6404, 16548
idx_error:	.asciz	"Unsupported character: "
.text
index_of_symbol:
	li		t0, 32
	li		t1, 127
	blt		a0, t0, index_of_invalid
	bgt		a0, t1, index_of_invalid
	sub		a0, a0, t0
	ret
index_of_invalid:
	mv		s0, a0
	li		a7, 4
	la		a0, idx_error
	ecall
	li		a7, 11
	mv		a0, s0
	ecall
	li		a0, '\n'
	ecall
	li		a7, 10
	ecall
#####
.data
.text	
load_symbol:
	addi	sp, sp, -4
	sw		ra, (sp)
	#
	slli	a0, a0, 1
	la		t0, indices
	add		t0, t0, a0
	lhu		a0, (t0)
	#
	lw		ra, (sp)
	addi	sp, sp, +4
	ret