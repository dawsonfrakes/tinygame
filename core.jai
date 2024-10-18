CPU_Endianness :: enum u32 {
	UNKNOWN :: 0;
	LITTLE :: 1;
	BIG :: 2;
}

ENDIAN :: #run -> CPU_Endianness {
	if #complete CPU == {
	case .UNINITIALIZED; #through;
	case .KRAMPU; #through;
	case .CUSTOM;
		return .UNKNOWN;
	case .X64; #through;
	case .ARM64;
		return .LITTLE;
	}
}

native_to_little :: inline (x: $T) -> T {
	return ifx ENDIAN == .LITTLE x else BitOps.byte_swap(x);
}

native_to_big :: inline (x: $T) -> T {
	return ifx ENDIAN == .BIG x else BitOps.byte_swap(x);
}

ascii_to_utf16le_string_literal :: ($s: string) -> []u16 {
	utf16le : [s.count + 1]u16;
	for 0..s.count - 1 utf16le[it] = native_to_little(cast(u16) s[it]);
	return utf16le;
}

#scope_file

BitOps :: #import "Bit_Operations";
Compiler :: #import "Compiler";
