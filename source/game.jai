RectVertex :: struct {
    position : Vector3;
}

avatar_half_dim :: 32.0;
avatar_vertices :: RectVertex.[
    .{.{-avatar_half_dim, -avatar_half_dim, 0.0}},
    .{.{+avatar_half_dim, -avatar_half_dim, 0.0}},
    .{.{+avatar_half_dim, +avatar_half_dim, 0.0}},
    .{.{-avatar_half_dim, +avatar_half_dim, 0.0}},
];
avatar_indices :: u8.[0, 1, 2, 2, 3, 0];

Avatar :: struct {
    position : Vector2;
    velocity : Vector2;
    scale : Vector2;
    rotation : float32;
    friend_index : s32;
    is_alive := true;
}

AVATARS_MAX :: 64 * 32;
AVATARS_MAX_INIT_VELOCITY_MULTIPLIER :: 29.0;
avatars_data : [AVATARS_MAX] Avatar = ---;
dead_avatars_data : [AVATARS_MAX] s64 = ---;
avatars : [] Avatar;
dead_avatars : [] s64;

_init_avatars :: (do_reset_of_dead_only: bool) {
    avatars.data = avatars_data.data;
    avatars.count = #ifx STEAM steam_friend_count else 0;
    y := avatar_half_dim;
    index := 0;
    for row: 0..7 {
        x := avatar_half_dim;
        for col: 0..12 {
            if index >= avatars.count break row;
            if !do_reset_of_dead_only || avatars[index].is_alive
                avatars[index] = .{
                    position=.{x, y},
                    scale=.{1.0, 1.0},
                    friend_index = xx index,
                    velocity = .{
                        (random_get_zero_to_one() * 2.0 - 1.0) * AVATARS_MAX_INIT_VELOCITY_MULTIPLIER,
                        (random_get_zero_to_one() * 2.0 - 1.0) * AVATARS_MAX_INIT_VELOCITY_MULTIPLIER,
                    },
                };
            x += avatar_half_dim + 64.0;
            index += 1;
        }
        y += avatar_half_dim + 64.0;
    }
}

init_avatars :: #bake_arguments _init_avatars(do_reset_of_dead_only=false);
restart_avatars_that_are_still_alive :: #bake_arguments _init_avatars(do_reset_of_dead_only=true);

avatar_to_world_matrix :: (using avatar: *Avatar) -> Matrix4 #no_context {
    x_scale_view := 1.0 / max(1.0, platform_screen_width / 2.0);
    y_scale_view := 1.0 / max(1.0, platform_screen_height / 2.0);

    result := Matrix4.{.[
        x_scale_view, 0.0, 0.0, 0.0,
        0.0, y_scale_view, 0.0, 0.0,
        0.0, 0.0, 1.0, 0.0,
        -1.0, -1.0, 0.0, 1.0,
    ]} * Matrix4.{.[
        1.0, 0.0, 0.0, 0.0,
        0.0, 1.0, 0.0, 0.0,
        0.0, 0.0, 1.0, 0.0,
        position.x, position.y, 0.0, 1.0,
    ]} * Matrix4.{.[
        scale.x, 0.0, 0.0, 0.0,
        0.0, scale.y, 0.0, 0.0,
        0.0, 0.0, 1.0, 0.0,
        0.0, 0.0, 0.0, 1.0,
    ]};
    return result;
}

game_initted := false;

game_do_reset := false;

game_update :: () {
    if !game_initted {
        game_initted = true;
        init_avatars();

        dead_avatars.data = dead_avatars_data.data;
    }

    dead_avatars.count = 0;

    if game_do_reset {
        game_do_reset = false;
        restart_avatars_that_are_still_alive();
    }

    for * avatars {
        if !it.is_alive continue;
        it.velocity.x = it.velocity.x * 0.99;
        it.velocity.y = it.velocity.y * 0.99;
        it.position.x += it.velocity.x;
        it.position.y += it.velocity.y;

        if it.position.x < avatar_half_dim {
            it.position.x = avatar_half_dim;
            it.velocity.x = -it.velocity.x;
        }

        if it.position.y < avatar_half_dim {
            it.position.y = avatar_half_dim;
            it.velocity.y = -it.velocity.y;
        }

        if it.position.x > cast(float) (platform_screen_width-1-avatar_half_dim) {
            it.position.x = cast(float) (platform_screen_width-1-avatar_half_dim);
            it.velocity.x = -it.velocity.x;
        }

        if it.position.y > cast(float) (platform_screen_height-1-avatar_half_dim) {
            it.position.y = cast(float) (platform_screen_height-1-avatar_half_dim);
            it.velocity.y = -it.velocity.y;
        }

        overlapping :: (a: Avatar, b: Avatar) -> bool {
            return abs(a.position.x - b.position.x) < 2 * avatar_half_dim * (a.scale.x + b.scale.x) / 2.0 &&
                abs(a.position.y - b.position.y) < 2 * avatar_half_dim * (a.scale.y + b.scale.y) / 2.0;
        }

        for other_index : it_index+1..avatars.count-1 {
            other := avatars[other_index];
            if !other.is_alive continue;
            if overlapping(it, other) {
                dead_avatars_data[dead_avatars.count] = it_index;
                dead_avatars.count += 1;
                dead_avatars_data[dead_avatars.count] = other_index;
                dead_avatars.count += 1;
                break;
            }
        }
    }

    for dead_avatars {
        avatars[it].is_alive = false;
    }
}

#import "Random";
