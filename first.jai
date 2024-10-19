#import "Basic";
#import "Compiler";
#import "File";
#import "File_Utilities";
#if OS == .WINDOWS {
    #import "Ico_File";
    #import "Windows_Resources";
}

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

	compiler_begin_intercept(w);
	add_build_file("source/platform.jai", w);

	while true {
        message := compiler_wait_for_message();
        if message.workspace != w continue;
        if message.kind == .COMPLETE break;
    }

    compiler_end_intercept(w);

    #if OS == .WINDOWS {
        exe_path := tprint(".build/%.exe", options.output_executable_name);
        ico_data := create_ico_file_from_bitmap_filename("resources/icon.bmp");
        success := set_icon_by_data(exe_path, ico_data);
        if !success print("failed to set exe icon\n");
    }

	write_entire_file(".build/steam_appid.txt", "480");
	copy_file("stupid_windows_garbage/steam_api64.dll", ".build/steam_api64.dll");
}

#run,stallable build();
