shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(1.0);
uniform float width : hint_range(0.0, 30.0) = 1.0;

// Blinking modulates the base color.
uniform vec4 blink_color : source_color = vec4(1.0);
uniform float blink_time_scale : hint_range(0.0, 10.0, 0.1) = 0.0;

void fragment() {
    // Calculate the size of one pixel scaled by your width
    vec2 size = TEXTURE_PIXEL_SIZE * width;
    
    // Check alpha in 4 directions (plus diagonals for a fuller look)
    float alpha = texture(TEXTURE, UV).a;
    alpha = max(alpha, texture(TEXTURE, UV + vec2(0.0, -size.y)).a); // Up
    alpha = max(alpha, texture(TEXTURE, UV + vec2(0.0, size.y)).a);  // Down
    alpha = max(alpha, texture(TEXTURE, UV + vec2(-size.x, 0.0)).a); // Left
    alpha = max(alpha, texture(TEXTURE, UV + vec2(size.x, 0.0)).a);  // Right
    
    // Sample the original texture color
    vec4 sprite_color = texture(TEXTURE, UV);
    
    // Apply the blinking logic to the sprite color
    float blink = 0.5 - 0.5 * cos(TIME * blink_time_scale);
    vec4 modulated_color = mix(sprite_color, sprite_color * blink_color, blink);
    
    // If the original pixel is transparent (alpha ~ 0) but the neighbor is solid (alpha > 0),
    // then draw the outline color. Otherwise, draw the sprite.
    vec3 final_rgb = mix(outline_color.rgb, modulated_color.rgb, sprite_color.a);
    float final_alpha = max(alpha, sprite_color.a) * outline_color.a;
    
    COLOR = vec4(final_rgb, final_alpha);
}