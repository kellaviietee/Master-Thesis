extends Sprite

export(Texture) var estonian_texture 

func _ready():
	if TranslationServer.get_locale() == "et":
		texture = estonian_texture
		
