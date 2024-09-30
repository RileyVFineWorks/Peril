const std = @import("std");
const ray = @import("raylib");
const globals = @import("globals.zig");

pub const MapCell = enum(u8) {
    empty = 0,
    wall = 1,
};

pub const Map = struct {
    width: usize,
    height: usize,
    data: []MapCell,

    pub fn isWall(self: Map, x: f32, z: f32) bool {
        const mapX = @as(usize, @intFromFloat(@floor(x / 2.0)));
        const mapZ = @as(usize, @intFromFloat(@floor(z / 2.0)));
        if (mapX >= self.width or mapZ >= self.height or mapX < 0 or mapZ < 0) {
            return true; // treat out-of-bounds as walls
        }
        return self.get(mapX, mapZ) == .wall;
    }

    pub fn init(allocator: std.mem.Allocator, width: usize, height: usize) !Map {
        const data = try allocator.alloc(MapCell, width * height);
        @memset(data, .empty);
        return Map{ .width = width, .height = height, .data = data };
    }

    // release map memory
    pub fn deinit(self: *Map, allocator: std.mem.Allocator) void {
        allocator.free(self.data);
    }

    pub fn get(self: Map, x: usize, y: usize) MapCell {
        return self.data[y * self.width + x];
    }

    pub fn set(self: *Map, x: usize, y: usize, value: MapCell) void {
        self.data[y * self.width + x] = value;
    }

    pub fn render(self: Map) void {
        for (0..self.height) |y| {
            for (0..self.width) |x| {
                switch (self.get(x, y)) {
                    .wall => {
                        const pos = ray.Vector3{
                            .x = @as(f32, @floatFromInt(x)) * 2.0,
                            .z = @as(f32, @floatFromInt(y)) * 2.0,
                            .y = 1.0,
                        };
                        ray.drawCube(pos, 2.0, 2.0, 2.0, ray.Color.gray);
                        ray.drawCubeWires(pos, 2.0, 2.0, 2.0, ray.Color.dark_gray);
                    },
                    .empty => {},
                }
            }
        }
    }
};
