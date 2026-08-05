shader_type canvas_item;

uniform float progress : hint_range(0, 1);
uniform bool reveal = false;
uniform float diamondPixelSize = 10.0;

void fragment() {
	float xFraction = fract(FRAGCOORD.x / diamondPixelSize);
	float yFraction = fract(FRAGCOORD.y / diamondPixelSize);
	float xDistance = abs(xFraction - 0.5);
	float yDistance = abs(yFraction - 0.5);
	float pos = UV.x + UV.y;
	float front = progress * 3.0;
	float bandWidth = mix(0.15, 1.5, progress);
	float band = (xDistance + yDistance) * bandWidth;
	bool covered = reveal ? (pos - band > front) : (pos + band < front);
	if (!covered) {
		discard;
	}
}