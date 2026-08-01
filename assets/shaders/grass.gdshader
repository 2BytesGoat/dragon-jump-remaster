shader_type canvas_item;

uniform float skew = 0.0;
uniform bool anchor_at_top = false;
uniform float sprite_y_offset = -8.0;

void vertex() {
    float y = VERTEX.y - sprite_y_offset;
    float height = 1.0 / TEXTURE_PIXEL_SIZE.y;

    float weight;

    if (anchor_at_top) {
        weight = y / height;
		VERTEX.x += weight * skew;
    } else {
        VERTEX.x += (1.0-UV.y) * skew;
    }
}