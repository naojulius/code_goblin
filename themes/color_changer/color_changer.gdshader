shader_type canvas_item;

// La nouvelle couleur qui remplacera le rouge (modifiable dans l'Inspecteur)
uniform vec4 target_color : source_color = vec4(0.0, 0.6, 1.0, 1.0); // Bleu par défaut

// Sensibilité du filtre (plus la valeur est haute, plus le filtre est strict sur le rouge)
uniform float threshold : hint_range(0.0, 1.0) = 0.2;

void fragment() {
	// 1. Récupère la couleur originale du pixel (avec la texture du Sprite/ColorRect)
	vec4 tex_color = texture(TEXTURE, UV);
	
	// 2. Calcule à quel point ce pixel est "rouge" par rapport au vert et au bleu
	// (R - max(G, B)) donne une valeur forte uniquement sur le rouge pur
	float red_dominance = max(0.0, tex_color.r - max(tex_color.g, tex_color.b));
	
	// 3. Crée un masque fluide grâce à smoothstep
	float mask = smoothstep(threshold, threshold + 0.2, red_dominance);
	
	// 4. Conserve la luminosité (valeur) d'origine pour garder les ombres et détails du dessin
	float luminance = max(tex_color.r, max(tex_color.g, tex_color.b));
	vec3 new_color_shaded = target_color.rgb * luminance;
	
	// 5. Applique le remplacement de couleur sans toucher à la transparence (Alpha)
	COLOR = vec4(mix(tex_color.rgb, new_color_shaded, mask), tex_color.a);
}