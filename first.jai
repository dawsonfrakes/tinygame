#import "Basic";
#import "Compiler";
#import "Process";

build :: () {
	options := get_build_options();
	set_build_options_dc(.{do_output=false});

	options.output_type = .EXECUTABLE;
	options.runtime_support_definitions = .OMIT;
	options.output_executable_name = "Colliders";

	w := compiler_create_workspace("Colliders");
	set_build_options(options, w);
	set_build_options_dc(.{append_linker_arguments=.["-subsystem:windows", "-entry:RawEntryPoint"]}, w);
	add_build_file("game.jai", w);
}

#run build();
