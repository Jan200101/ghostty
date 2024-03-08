const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;

/// The possible reference locations for a point. When someone says "(42, 80)" in the context of a terminal, that could mean multiple
/// things: it is in the current visible viewport? the current active
/// area of the screen where the cursor is? the entire scrollback history?
/// etc. This tag is used to differentiate those cases.
pub const Tag = enum {
    /// Top-left is part of the active area where a running program can
    /// jump the cursor and make changes. The active area is the "editable"
    /// part of the screen.
    ///
    /// The bottom-right of the active tag differs from all other tags
    /// because it includes the full height (rows) of the screen, including
    /// rows that may not be written yet. This is required because the active
    /// area is fully "addressable" by the running program (see below) whereas
    /// the other tags are used primarliy for reading/modifying past-written
    /// data so they can't address unwritten rows.
    ///
    /// Note for those less familiar with terminal functionality: there
    /// are escape sequences to move the cursor to any position on
    /// the screen, but it is limited to the size of the viewport and
    /// the bottommost part of the screen. Terminal programs can't --
    /// with sequences at the time of writing this comment -- modify
    /// anything in the scrollback, visible viewport (if it differs
    /// from the active area), etc.
    active,

    /// Top-left is the visible viewport. This means that if the user
    /// has scrolled in any direction, top-left changes. The bottom-right
    /// is the last written row from the top-left.
    viewport,

    /// Top-left is the furthest back in the scrollback history
    /// supported by the screen and the bottom-right is the bottom-right
    /// of the last written row. Note this last point is important: the
    /// bottom right is NOT necessarilly the same as "active" because
    /// "active" always allows referencing the full rows tall of the
    /// screen whereas "screen" only contains written rows.
    screen,

    /// The top-left is the same as "screen" but the bottom-right is
    /// the line just before the top of "active". This contains only
    /// the scrollback history.
    history,
};

/// An x/y point in the terminal for some definition of location (tag).
pub const Point = union(Tag) {
    active: Coordinate,
    viewport: Coordinate,
    screen: Coordinate,
    history: Coordinate,

    pub const Coordinate = struct {
        x: usize = 0,
        y: usize = 0,
    };

    pub fn coord(self: Point) Coordinate {
        return switch (self) {
            .active,
            .viewport,
            .screen,
            .history,
            => |v| v,
        };
    }
};

/// A point in the terminal that is always in the viewport area.
pub const Viewport = struct {
    x: usize = 0,
    y: usize = 0,

    pub fn eql(self: Viewport, other: Viewport) bool {
        return self.x == other.x and self.y == other.y;
    }
};

/// A point in the terminal that is in relation to the entire screen.
pub const Screen = struct {
    x: usize = 0,
    y: usize = 0,
};
