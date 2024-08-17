const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    //option needed for cmake to communicate where the build dir is (expected output of CMAKE_CURRENT_BINARY_DIR)
    const output_dir = b.option([]const u8, "output_dir", "Directory to output lib") orelse "lib";

    //Here we call getRelativePath() function to get the relative path to CMAKE_CURRENT_BINARY_DIR
    //and concate it to ../ because normal output dir is not zig_root_dir but zig_root_dir/zig-out
    //WARNING
    //If you wish to use the same path to get objects to link against, you must maintain the same path and
    //not prepend the ../ directory
    const relative_output_dir = concatString(b, "../", getRelativePath(b, output_dir));

    std.debug.print("output_dir = {s}\n", .{output_dir});
    std.debug.print("relative_output_dir = {s}\n", .{relative_output_dir});

    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addSharedLibrary(.{
        .name = "zig",
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    //needed to be linked by C code
    lib.bundle_compiler_rt = true;

    //use output dir for install
    const target_output = b.addInstallArtifact(lib, .{
        .dest_dir = .{
            .override = .{
                .custom = relative_output_dir,
            },
        },
    });
    b.getInstallStep().dependOn(&target_output.step);

    //Tests not changed
    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}

//helper functions
//WARNING this code is bad and can most likely be improved
//
//getRelativePath takes in a path and output a relative path from current working directory
fn getRelativePath(b: *std.Build, output_dir: []const u8) []const u8 {
    if (std.fs.path.isAbsolute(output_dir)) {
        if (std.fs.cwd().realpathAlloc(b.allocator, ".")) |cwd| {
            return std.fs.path.relative(b.allocator, cwd, output_dir) catch |e| {
                std.debug.print("Error on relative path {}", .{e});
                return output_dir;
            };
        } else |err| {
            std.debug.print("Error on relative cwd path {}", .{err});
            return output_dir;
        }
    } else {
        return output_dir;
    }
}

//concatString concat two string slices, not null terminated
fn concatString(b: *std.Build, s1: []const u8, s2: []const u8) []const u8 {
    var result = b.allocator.alloc(u8, s1.len + s2.len) catch |err| {
        std.debug.print("concatString error {}\n", .{err});
        return "error";
    };
    for (s1, 0..) |char, index| {
        result[index] = char;
    }
    const index_base = s1.len;
    for (s2, 0..) |char, index| {
        result[index_base + index] = char;
    }
    return result;
}
