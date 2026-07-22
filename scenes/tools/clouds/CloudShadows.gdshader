shader_type canvas_item;

// Texture du sol (fournie automatiquement par Godot si appliqué à un Sprite/TileMap)
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// Paramètres configurables depuis l'Inspecteur
uniform vec2 scroll_direction = vec2(1.0, 0.3);
uniform float scroll_speed : hint_range(0.01, 0.2) = 0.03;
uniform float shadow_density : hint_range(0.0, 1.0) = 0.55;
uniform float shadow_softness : hint_range(0.01, 0.5) = 0.15;
uniform vec4 shadow_color : source_color = vec4(0.05, 0.08, 0.15, 0.4);

// Texture de bruit (NoiseTexture2D à assigner dans l'inspecteur)
uniform sampler2D noise_texture : repeat_enable, filter_linear;

void fragment() {
    // 1. Calcul du décalage continu basé sur le temps
    vec2 moving_uv = UV + (scroll_direction * TIME * scroll_speed);
    
    // Échantillonnage du bruit
    float noise_val = texture(noise_texture, moving_uv).r;
    
    // 2. Adoucissement des contours de l'ombre (smoothstep au lieu de threshold dur)
    float shadow_mask = smoothstep(shadow_density - shadow_softness, shadow_density + shadow_softness, noise_val);
    
    // 3. Application de l'ombre transparente sur le pixel
    COLOR = vec4(shadow_color.rgb, shadow_mask * shadow_color.a);
}