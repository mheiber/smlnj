(* icon-bitmap.sml
 * this file created by bm2mlx
 * from:  icon_bitmap
 * on: Wed Mar 13 12:32:27 EST 1991
 *)
structure IconBitmap : sig

    val iconBitmap : EXeneBase.image

  end = struct

    val iconBitmap = EXeneBase.imageFromAscii (40, [[
	    "0b1100001111000011111111100000000000011110",
	    "0b0000000000000000000000000000000000000011",
	    "0b0000000000000000000000000000000000000001",
	    "0b0001110000000000000000100000000000000001",
	    "0b0010010000000000000000000000000000000001",
	    "0b0010001000000000000000000000000000000001",
	    "0b0010001000000000000000000000000000000001",
	    "0b0010111000000000111100000011000000000000",
	    "0b0011111001111100100000100111000000000000",
	    "0b0010001001000100100000100100000000000000",
	    "0b0010000101000100011000100100000000000000",
	    "0b0011100101100100001100110100000000000000",
	    "0b0001111000111100101100110110110000000001",
	    "0b0000000000000100011000000011000000000001",
	    "0b1000000000000000000000000000000000000001",
	    "0b1000000001000000000000100000000000000001",
	    "0b1000000001100000000000100000000000000001",
	    "0b1000000000100000000001000000000000000001",
	    "0b1000000000100000000001001000000000000001",
	    "0b1000000000100000000001000000000000000001",
	    "0b1000000000100000010001000000000000000001",
	    "0b1000000000100000110011001000111110000001",
	    "0b1000000000010001010010001000110011000000",
	    "0b1000000000010001010010001000100001000000",
	    "0b0000000000010001010010001000100001000000",
	    "0b0000000000010010010110001000100001000000",
	    "0b0000000000001110001000001001100001000001",
	    "0b1000000000000000000000000000000000000001",
	    "0b1000000000000000000000000001110000000001",
	    "0b1000000000000000000000000111001100000001",
	    "0b1000000000000000000000001100000110000001",
	    "0b1000000111100000000000011000000010000001",
	    "0b1000011100100000000000110000000011000001",
	    "0b1000110000010000000000100000000001000001",
	    "0b0000100000010000000001000000000001000001",
	    "0b1001100000001000000011000000000001100001",
	    "0b0011000000001100000110000000000000100001",
	    "0b0010000000000110011100000000000000111011",
	    "0b0100000000000001110000000000000000001110",
	    "0b0000000000000000000000000000000000000000"
	  ]])

  end (* IconBitmap *)