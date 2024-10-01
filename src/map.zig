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
    wall_texture: ray.Texture2D,

    pub fn isWall(self: Map, x: f32, z: f32) bool {
        const mapX = @as(i32, @intFromFloat(@floor(x / 2.0)));
        const mapZ = @as(i32, @intFromFloat(@floor(z / 2.0)));

        if (mapX < 0 or mapX >= @as(i32, @intCast(self.width)) or
            mapZ < 0 or mapZ >= @as(i32, @intCast(self.height)))
        {
            return false;
        }

        return self.get(@intCast(mapX), @intCast(mapZ)) == .wall;
    }

    pub fn checkCollision(self: Map, x: f32, z: f32, radius: f32) bool {
        const checkPoints = [_][2]f32{
            .{ x + radius, z },
            .{ x - radius, z },
            .{ x, z + radius },
            .{ x, z - radius },
            .{ x + radius * 0.7, z + radius * 0.7 },
            .{ x + radius * 0.7, z - radius * 0.7 },
            .{ x - radius * 0.7, z + radius * 0.7 },
            .{ x - radius * 0.7, z - radius * 0.7 },
        };

        for (checkPoints) |point| {
            if (self.isWall(point[0], point[1])) {
                return true;
            }
        }

        return false;
    }

    pub fn init(allocator: std.mem.Allocator, width: usize, height: usize) !Map {
        const data = try allocator.alloc(MapCell, width * height);
        @memset(data, .empty);
        const wall_texture = ray.loadTexture("textures/wall_texture.png");
        return Map{ .width = width, .height = height, .data = data, .wall_texture = wall_texture };
    }

    // release map memory
    pub fn deinit(self: *Map, allocator: std.mem.Allocator) void {
        allocator.free(self.data);
        ray.unloadTexture(self.wall_texture);
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
