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
}

AVATARS_MAX :: 64 * 32;
avatars_data : [AVATARS_MAX] Avatar = ---;
avatars : [] Avatar;

init_avatars :: () {
    avatars.data = avatars_data.data;
    avatars.count = steam_friend_count;
    y := -cast(s32) platform_screen_height / 1.0 + 64.0 + 150.0;
    index := 0;
    for row: 0..7 {
        x := -cast(s32) platform_screen_width / 1.0 + 64.0 + 150.0;
        for col: 0..12 {
            if index >= avatars.count break row;
            avatars[index] = .{
                position=.{x, y},
                scale=.{1.0, 1.0},
                friend_index = xx index,
            };
            x += 128.0 + 50.0;
            index += 1;
        }
        y += 128.0 + 50.0;
    }
}

avatar_to_world_matrix :: (using avatar: *Avatar) -> Matrix4 #no_context {
    x_scale_view := 1.0 / max(1.0, cast(float32) platform_screen_width);
    y_scale_view := 1.0 / max(1.0, cast(float32) platform_screen_height);

    result := Matrix4.{.[
        x_scale_view, 0.0, 0.0, 0.0,
        0.0, y_scale_view, 0.0, 0.0,
        0.0, 0.0, 1.0, 0.0,
        0.0, 0.0, 0.0, 1.0,
    ]} * Matrix4.{.[
        scale.x, 0.0, 0.0, 0.0,
        0.0, scale.y, 0.0, 0.0,
        0.0, 0.0, 1.0, 0.0,
        0.0, 0.0, 0.0, 1.0,
    ]} * Matrix4.{.[
        1.0, 0.0, 0.0, 0.0,
        0.0, 1.0, 0.0, 0.0,
        0.0, 0.0, 1.0, 0.0,
        position.x, position.y, 0.0, 1.0,
    ]};
    return result;
}

game_initted := false;

game_update :: () {
    if !game_initted {
        game_initted = true;
        init_avatars();

        for * avatars
            it.velocity = .{
                random_get_zero_to_one() * 9.0,
                random_get_zero_to_one() * 9.0,
            };
    }

    for * avatars {
        it.velocity.x = max(0.0, it.velocity.x * 0.95);
        it.velocity.y = max(0.0, it.velocity.y * 0.95);
        it.position.x += it.velocity.x;
        it.position.y += it.velocity.y;
    }
}

#import "Random";
