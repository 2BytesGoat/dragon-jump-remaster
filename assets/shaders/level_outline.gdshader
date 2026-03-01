shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform vec4 tint_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float brightness_multiplier : hint_range(0.0, 5.0) = 1.0; 
uniform float thickness : hint_range(0.0, 10.0) = 1.0;

void fragment() {
    // 1. Get the current screen pixel
    vec4 c = textureLod(screen_texture, SCREEN_UV, 0.0);
    
    // 2. Original Alpha Pre-multiplication fix
    if (c.a > 0.0001) {
        c.rgb /= c.a;
    }

    // 3. Inner Outline Logic (Alpha Border Detection)
    float min_alpha = 1.0;
    vec2 ps = SCREEN_PIXEL_SIZE;

    if (c.a > 0.0001) {
        for (float x = -thickness; x <= thickness; x++) {
            for (float y = -thickness; y <= thickness; y++) {
                if (x == 0.0 && y == 0.0) continue;
                
                vec2 offset = vec2(x, y) * ps;
                float neighbor_a = textureLod(screen_texture, SCREEN_UV + offset, 0.0).a;
                min_alpha = min(min_alpha, neighbor_a);
                
                if (min_alpha <= 0.0) break;
            }
            if (min_alpha <= 0.0) break;
        }
    }

    // 4. Alpha-Aware Additive Output
    vec3 final_rgb = c.rgb;

    // Detect if we are on the inside edge (c.a is high, but neighbor alpha is low)
    if (c.a > 0.0001 && min_alpha < 0.1) {
        float luminance = dot(c.rgb, vec3(0.299, 0.587, 0.114));
        
        // The "intensity" is now a combination of the Multiplier AND the Tint Alpha
        float intensity = brightness_multiplier * tint_color.a;
        
        vec3 effect_layer = vec3(luminance) * tint_color.rgb * intensity;
        
        // Additive blend: Base + (Tint * Alpha * Multiplier)
        final_rgb = c.rgb + effect_layer;
    }

    // Apply vertex color (COLOR) and original alpha to finish
    COLOR = vec4(final_rgb, c.a) * COLOR;
}