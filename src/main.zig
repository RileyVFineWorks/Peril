const std = @import("std");
const ray = @import("raylib");
const globals = @import("globals.zig");
const Map = @import("map.zig").Map;

pub const SCREEN_WIDTH = globals.SCREEN_WIDTH;
pub const SCREEN_HEIGHT = globals.SCREEN_HEIGHT;

pub fn main() !void {
    ray.initWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Wolfenstein 3D-like in Zig with Raylib");
    defer ray.closeWindow();

    ray.setTargetFPS(60);

    var camera = ray.Camera{
        .position = .{ .x = 4.0, .y = 2.0, .z = 4.0 },
        .target = .{ .x = 0.0, .y = 1.0, .z = 0.0 },
        .up = .{ .x = 0.0, .y = 1.0, .z = 0.0 },
        .fovy = 60.0,
        .projection = ray.CameraProjection.camera_perspective,
    };

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var map = try Map.init(allocator, 100, 100);
    defer map.deinit(allocator);

    map.set(0, 0, .wall);
    map.set(1, 0, .wall);
    map.set(2, 0, .wall);
    map.set(0, 1, .wall);
    map.set(0, 2, .wall);

    while (!ray.windowShouldClose()) {
        const old_position = camera.position;
        ray.updateCamera(&camera, .camera_first_person);

        if (map.isWall(camera.position.x, camera.position.z)) {
            camera.position = old_position;
        }

        ray.beginDrawing();
        defer ray.endDrawing();

        ray.clearBackground(ray.Color.white);

        ray.beginMode3D(camera);
        {
            map.render();
            ray.drawGrid(100, 1.0);
        }
        ray.endMode3D();

        ray.drawFPS(10, 10);
    }
}
