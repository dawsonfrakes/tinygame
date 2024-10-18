#import "Basic";
#import "Compiler";
#import "File";
#import "File_Utilities";

build :: () {
	options := get_build_options();
	set_build_options_dc(.{do_output=false});

	options.output_type = .EXECUTABLE;
	options.runtime_support_definitions = .OMIT;
	options.output_executable_name = "Colliders";
	options.output_path = tprint("%/.build", #filepath);

	w := compiler_create_workspace("Colliders");
	set_build_options(options, w);
	set_build_options_dc(.{append_linker_arguments=.["-subsystem:windows", "-entry:RawEntryPoint"]}, w);
	add_build_file("game.jai", w);

	write_entire_file(".build/steam_appid.txt", "480");
	copy_file("libs/steam_api64.dll", ".build/steam_api64.dll");
}

#run build();
