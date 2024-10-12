const core = struct {
	const builtin = @import("builtin");

	pub const build_mode = builtin.mode;
	pub const os_tag = builtin.target.os.tag;
	pub const cpu_arch = builtin.target.cpu.arch;
	pub const cpu_bits = builtin.target.ptrBitWidth();
	pub const cpu_endianness = builtin.target.cpu.arch.endian();

	pub const Type = @TypeOf(@typeInfo(type));
	pub const CallingConvention = @TypeOf(@typeInfo(fn () void).@"fn".calling_convention);

	pub const mem = struct {
		pub fn zeroes(comptime T: type) T {
			return @as(*align(1) const T, @ptrCast(&[_]u8{0} ** @sizeOf(T))).*;
		}

		pub fn zeroInit(comptime T: type, args: anytype) T {
			var result: T = undefined;
			inline for (@typeInfo(T).@"struct".fields) |field| {
				@field(result, field.name) = if (@hasField(@TypeOf(args), field.name))
					switch (@typeInfo(field.type)) {
						.@"struct" => zeroInit(field.type, @field(args, field.name)),
						else => @field(args, field.name),
					}
				else if (field.default_value) |default_value|
					@as(*align(1) const field.type, @ptrCast(default_value)).*
				else
					zeroes(field.type);
			}
			return result;
		}
	};

	pub const windows = struct {
		pub const WINAPI: core.CallingConvention = if (core.cpu_arch == .x86) .Stdcall else .C;

		pub const kernel32 = struct {
			pub extern "kernel32" fn Sleep(c_uint) callconv(WINAPI) void;
			pub extern "kernel32" fn ExitProcess(c_uint) callconv(WINAPI) noreturn;
		};

		pub const user32 = struct {
			pub extern "user32" fn SetProcessDPIAware() callconv(WINAPI) c_int;
		};

		pub const winmm = struct {
			pub const TIMERR_NOERROR = 0;

			pub extern "winmm" fn timeBeginPeriod(c_uint) callconv(WINAPI) c_uint;
		};
	};
};

pub usingnamespace switch (core.os_tag) {
	.windows => struct {
		const w = struct {
			usingnamespace core.windows;
			usingnamespace core.windows.kernel32;
			usingnamespace core.windows.user32;
			usingnamespace core.windows.winmm;
		};

		pub export fn WinMainCRTStartup() callconv(w.WINAPI) noreturn {
			@setAlignStack(16);

			const sleep_is_granular = w.timeBeginPeriod(1) == w.TIMERR_NOERROR;

			_ = w.SetProcessDPIAware();

			if (sleep_is_granular) {
				w.Sleep(1);
			}

			w.ExitProcess(0);
		}
	},
	else => @compileError("Unsupported OS"),
};
