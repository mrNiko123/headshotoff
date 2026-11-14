extends RefCounted





const RARITY: = {
	"common": {"label": "COMMON", "color": Color(0.62, 0.67, 0.72, 1.0)}, 
	"rare": {"label": "RARE", "color": Color(0.33, 0.64, 0.93, 1.0)}, 
	"epic": {"label": "EPIC", "color": Color(0.66, 0.42, 0.95, 1.0)}, 
	"legendary": {"label": "LEGENDARY", "color": Color(0.93, 0.64, 0.23, 1.0)}, 
}

const WEAPONS: = {
	"awp": {
		"name": "AWP", 
		"type": "sniper", 
		"automatic": false, 
		"fire_rate": 1.32, 
		"spread": 0.0012, 
		"recoil": 0.068, 
		"recoil_side": 0.0018, 
		"magazine": 5, 
		"reload_time": 2.55, 
		"zoom_fov": 22.0, 

		"damage_body": 100.0, 
		"damage_head": 150.0, 
		"damage_legs": 70.0, 
		"skins": {




			"default": {
				"name": "CLASSIC", "rarity": "common", 
				"body": Color(0.13, 0.28, 0.4, 1.0), 
				"accent": Color(0.4, 0.86, 0.78, 1.0), 
				"grip": Color(0.08, 0.12, 0.16, 1.0), 
				"hue": 0.55, 
				"saturation": 1.0, 
				"value": 1.0, 
			}, 
			"asiimov": {
				"name": "ASIMOV", "rarity": "legendary", 
				"body": Color(0.92, 0.9, 0.86, 1.0), 
				"accent": Color(0.95, 0.55, 0.14, 1.0), 
				"hue": 0.08, 
				"saturation": 0.35, 
				"value": 1.4, 
			}, 
			"ultraviolet": {
				"name": "Ультрафиолет", "rarity": "legendary", 
				"body": Color("#2b1055"), "accent": Color("#a855ff"), 
				"grip": Color("#0a0612"), 
			}, 
			"crimson_night": {
				"name": "Багровая ночь", "rarity": "rare", 
				"body": Color("#0d0d10"), "accent": Color("#e0202f"), 
				"grip": Color("#050506"), 
			}, 
			"glacier": {
				"name": "Ледник", "rarity": "common", 
				"body": Color("#b8d8ef"), "accent": Color("#3d7fb8"), 
				"grip": Color("#10202f"), 
			}, 
			"toxic": {
				"name": "Токсин", "rarity": "rare", 
				"body": Color("#0d140a"), "accent": Color("#8cff2a"), 
				"grip": Color("#050805"), 
			}, 
			"gilded": {
				"name": "Позолота", "rarity": "epic", 
				"body": Color("#c9a227"), "accent": Color("#1a1a1a"), 
				"grip": Color("#2b1f08"), 
			}, 
		}, 
	}, 



	"ak47": {
		"name": "AK-47", 
		"type": "rifle", 
		"automatic": true, 
		"fire_rate": 0.1, 
		"spread": 0.0085, 




		"recoil": 0.055, 
		"recoil_side": 0.007, 
		"recoil_recovery": 2.0, 
		"recoil_limit": 18.0, 
		"magazine": 30, 
		"reload_time": 2.4, 


		"damage_body": 36.0, 
		"damage_head": 108.0, 
		"damage_legs": 26.0, 
		"skins": {
			"classic": {
				"name": "CLASSIC", "rarity": "common", 
				"body": Color(0.24, 0.25, 0.28, 1.0), 
				"accent": Color(0.66, 0.16, 0.14, 1.0), 
			}, 
			"vulcan": {
				"name": "VULCAN", "rarity": "rare", 
				"body": Color(0.62, 0.66, 0.72, 1.0), 
				"accent": Color(0.16, 0.45, 0.78, 1.0), 
			}, 
			"ultraviolet": {
				"name": "Ультрафиолет", "rarity": "legendary", 
				"body": Color("#2b1055"), "accent": Color("#a855ff"), 
				"grip": Color("#0a0612"), 
			}, 
			"crimson_night": {
				"name": "Багровая ночь", "rarity": "rare", 
				"body": Color("#0d0d10"), "accent": Color("#e0202f"), 
				"grip": Color("#050506"), 
			}, 
			"glacier": {
				"name": "Ледник", "rarity": "common", 
				"body": Color("#b8d8ef"), "accent": Color("#3d7fb8"), 
				"grip": Color("#10202f"), 
			}, 
			"toxic": {
				"name": "Токсин", "rarity": "rare", 
				"body": Color("#0d140a"), "accent": Color("#8cff2a"), 
				"grip": Color("#050805"), 
			}, 
			"gilded": {
				"name": "Позолота", "rarity": "epic", 
				"body": Color("#c9a227"), "accent": Color("#1a1a1a"), 
				"grip": Color("#2b1f08"), 
			}, 
		}, 
	}, 
	"m4a1": {
		"name": "M4A1-S", 
		"type": "rifle", 
		"automatic": true, 
		"fire_rate": 0.095, 
		"spread": 0.0062, 



		"recoil": 0.034, 
		"recoil_side": 0.004, 
		"recoil_recovery": 2.5, 
		"recoil_limit": 13.0, 
		"magazine": 20, 
		"reload_time": 2.15, 
		"damage_body": 33.0, 
		"damage_head": 100.0, 
		"damage_legs": 24.0, 
		"skins": {
			"steel": {
				"name": "CLASSIC", "rarity": "rare", 
				"body": Color(0.29, 0.31, 0.24, 1.0), 
				"accent": Color(0.74, 0.66, 0.4, 1.0), 
			}, 
			"printstream": {
				"name": "PRINTSTREAM", "rarity": "legendary", 
				"body": Color(0.88, 0.89, 0.9, 1.0), 
				"accent": Color(0.1, 0.1, 0.11, 1.0), 
			}, 
			"ultraviolet": {
				"name": "Ультрафиолет", "rarity": "legendary", 
				"body": Color("#2b1055"), "accent": Color("#a855ff"), 
				"grip": Color("#0a0612"), 
			}, 
			"crimson_night": {
				"name": "Багровая ночь", "rarity": "rare", 
				"body": Color("#0d0d10"), "accent": Color("#e0202f"), 
				"grip": Color("#050506"), 
			}, 
			"glacier": {
				"name": "Ледник", "rarity": "common", 
				"body": Color("#b8d8ef"), "accent": Color("#3d7fb8"), 
				"grip": Color("#10202f"), 
			}, 
			"toxic": {
				"name": "Токсин", "rarity": "rare", 
				"body": Color("#0d140a"), "accent": Color("#8cff2a"), 
				"grip": Color("#050805"), 
			}, 
			"gilded": {
				"name": "Позолота", "rarity": "epic", 
				"body": Color("#c9a227"), "accent": Color("#1a1a1a"), 
				"grip": Color("#2b1f08"), 
			}, 
		}, 
	}, 
	"deagle": {
		"name": "DESERT EAGLE", 
		"type": "pistol", 
		"automatic": false, 
		"fire_rate": 0.34, 
		"spread": 0.0028, 
		"spread_bloom": 0.016, 
		"bloom_decay": 3.0, 
		"recoil": 0.062, 
		"recoil_side": 0.004, 
		"recoil_recovery": 6.0, 
		"recoil_limit": 14.0, 
		"magazine": 7,
		"reload_time": 2.2, 
		"damage_body": 63.0, 
		"damage_head": 155.0, 
		"damage_legs": 27.0, 
		"skins": {
			"chrome": {
				"name": "CHROME", "rarity": "common", 
				"body": Color(0.22, 0.24, 0.28, 1.0), 
				"accent": Color(0.8, 0.6, 0.3, 1.0), 
				"metal": Color(0.8, 0.83, 0.88, 1.0), 
				"frame": Color(0.42, 0.45, 0.5, 1.0), 
				}, 
			"blaze": {
				"name": "BLAZE", "rarity": "epic", 
				"body": Color(0.4, 0.18, 0.08, 1.0), 
				"accent": Color(1.0, 0.5, 0.12, 1.0), 
				"metal": Color(0.82, 0.36, 0.1, 1.0), 
				"frame": Color(0.14, 0.14, 0.15, 1.0), 
			}, 
			"ultraviolet": {
				"name": "Ультрафиолет", "rarity": "legendary", 
				"metal": Color("#7a3cf0"), "frame": Color("#1a0a33"), 
			}, 
			"crimson_night": {
				"name": "Багровая ночь", "rarity": "rare", 
				"metal": Color("#c01626"), "frame": Color("#121214"), 
			}, 
			"glacier": {
				"name": "Ледник", "rarity": "common", 
				"metal": Color("#dff1fb"), "frame": Color("#4f84b0"), 
			}, 
			"toxic": {
				"name": "Токсин", "rarity": "rare", 
				"metal": Color("#7be22b"), "frame": Color("#0e1a0a"), 
			}, 
			"gilded": {
				"name": "Позолота", "rarity": "epic", 
				"metal": Color("#e2b93b"), "frame": Color("#3d2f0c"), 
			}, 
		}, 
	}, 
	"usp": {
		"name": "USP-S", 
		"type": "pistol", 
		"automatic": false, 
		"fire_rate": 0.16, 
		"spread": 0.003, 
		"spread_bloom": 0.006, 
		"bloom_decay": 4.0, 
		"recoil": 0.026, 
		"recoil_side": 0.002, 
		"recoil_recovery": 5.0, 
		"recoil_limit": 8.0, 
		"magazine": 12, 
		"reload_time": 2.2, 
		"damage_body": 35.0, 
		"damage_head": 140.0, 
		"damage_legs": 17.0, 
		"skins": {
			"stock": {
				"name": "STOCK", "rarity": "common", 
				"body": Color(0.08, 0.08, 0.09, 1.0), 
				"accent": Color(0.16, 0.16, 0.17, 1.0), 
				"metal": Color(0.1, 0.1, 0.11, 1.0), 
				"frame": Color(0.15, 0.15, 0.16, 1.0), 
			}, 
			"noir": {
				"name": "KILL CONFIRMED", "rarity": "epic", 
				"body": Color(0.82, 0.83, 0.86, 1.0), 
				"accent": Color(0.76, 0.16, 0.2, 1.0), 
				"metal": Color(0.86, 0.87, 0.9, 1.0), 
				"frame": Color(0.6, 0.14, 0.18, 1.0), 
			}, 
			"ultraviolet": {
				"name": "Ультрафиолет", "rarity": "legendary", 
				"metal": Color("#7a3cf0"), "frame": Color("#1a0a33"), 
			}, 
			"crimson_night": {
				"name": "Багровая ночь", "rarity": "rare", 
				"metal": Color("#c01626"), "frame": Color("#121214"), 
			}, 
			"glacier": {
				"name": "Ледник", "rarity": "common", 
				"metal": Color("#dff1fb"), "frame": Color("#4f84b0"), 
			}, 
			"toxic": {
				"name": "Токсин", "rarity": "rare", 
				"metal": Color("#7be22b"), "frame": Color("#0e1a0a"), 
			}, 
			"gilded": {
				"name": "Позолота", "rarity": "epic", 
				"metal": Color("#e2b93b"), "frame": Color("#3d2f0c"), 
			}, 
		}, 
	}, 
	"knife": {
		"name": "KNIFE", 
		"type": "knife", 
		"automatic": false, 
		"fire_rate": 0.66, 
		"spread": 0.0, 
		"recoil": 0.012, 
		"magazine": 0, 
		"reload_time": 0.0, 
		"melee_range": 2.4, 
		"skins": {
			"forest": {
				"name": "BUTTERFLY", "rarity": "common", 
				"tint": Color(1.0, 0.94, 0.86, 1.0), 
			}, 
			"lava": {
				"name": "LAVA FLOW", "rarity": "legendary", 
				"lava": true, 
				"tint": Color(1.0, 0.45, 0.08, 1.0), 
				"icon": Color(1.0, 0.4, 0.05, 1.0), 
			}, 




			"bayonet": {
				"name": "BAYONET", "rarity": "epic", 
				"model": "bayonet", 
				"tint": Color(1.0, 1.0, 1.0, 1.0), 
				"icon": Color(0.76, 0.82, 0.92, 1.0), 
			}, 
			"karambit": {
				"name": "KARAMBIT", "rarity": "legendary", 
				"model": "karambit", 
				"tint": Color(1.0, 1.0, 1.0, 1.0), 
				"icon": Color(0.95, 0.74, 0.36, 1.0), 
			}, 
			"skeleton": {
				"name": "SKELETON", "rarity": "epic", 
				"model": "skeleton", 
				"tint": Color(1.0, 1.0, 1.0, 1.0), 
				"icon": Color(0.62, 0.86, 0.78, 1.0), 
			}, 
			"dagger": {
				"name": "DUAL DAGGERS", "rarity": "rare", 
				"model": "dagger", 
				"tint": Color(1.0, 1.0, 1.0, 1.0), 
				"icon": Color(0.9, 0.55, 0.52, 1.0), 
			}, 
			"combat": {
				"name": "COMBAT KNIFE", "rarity": "rare", 
				"model": "combat", 
				"tint": Color(1.0, 1.0, 1.0, 1.0), 
				"icon": Color(0.7, 0.8, 0.58, 1.0), 
			}, 
			"nomad": {
				"name": "NOMAD", "rarity": "legendary", 
				"model": "nomad", 
				"tint": Color(1.0, 1.0, 1.0, 1.0), 
				"icon": Color(0.66, 0.78, 0.92, 1.0), 
			}, 
			"butterfly_ultraviolet": {
				"name": "БАБОЧКА | Ультрафиолет", "rarity": "legendary", 
				"texture": "res://assets/skins/knife/butterfly_ultraviolet.png", 
				"tint": Color.WHITE, "icon": Color(0.63, 0.33, 0.95, 1.0), 
			}, 
			"butterfly_crimson_night": {
				"name": "БАБОЧКА | Багровая ночь", "rarity": "rare", 
				"texture": "res://assets/skins/knife/butterfly_crimson_night.png", 
				"tint": Color.WHITE, "icon": Color(0.88, 0.13, 0.19, 1.0), 
			}, 
			"butterfly_glacier": {
				"name": "БАБОЧКА | Ледник", "rarity": "common", 
				"texture": "res://assets/skins/knife/butterfly_glacier.png", 
				"tint": Color.WHITE, "icon": Color(0.72, 0.85, 0.94, 1.0), 
			}, 
			"butterfly_toxic": {
				"name": "БАБОЧКА | Токсин", "rarity": "rare", 
				"texture": "res://assets/skins/knife/butterfly_toxic.png", 
				"tint": Color.WHITE, "icon": Color(0.55, 1.0, 0.16, 1.0), 
			}, 
			"butterfly_gilded": {
				"name": "БАБОЧКА | Позолота", "rarity": "epic", 
				"texture": "res://assets/skins/knife/butterfly_gilded.png", 
				"tint": Color.WHITE, "icon": Color(0.79, 0.64, 0.15, 1.0), 
			}, 
			"bayonet_ultraviolet": {
				"name": "БАЙОНЕТ | Ультрафиолет", "rarity": "legendary", 
				"model": "bayonet", 
				"texture": "res://assets/skins/knife/bayonet_ultraviolet.png", 
				"tint": Color.WHITE, "icon": Color(0.63, 0.33, 0.95, 1.0), 
			}, 
			"bayonet_crimson_night": {
				"name": "БАЙОНЕТ | Багровая ночь", "rarity": "rare", 
				"model": "bayonet", 
				"texture": "res://assets/skins/knife/bayonet_crimson_night.png", 
				"tint": Color.WHITE, "icon": Color(0.88, 0.13, 0.19, 1.0), 
			}, 
			"bayonet_glacier": {
				"name": "БАЙОНЕТ | Ледник", "rarity": "common", 
				"model": "bayonet", 
				"texture": "res://assets/skins/knife/bayonet_glacier.png", 
				"tint": Color.WHITE, "icon": Color(0.72, 0.85, 0.94, 1.0), 
			}, 
			"bayonet_toxic": {
				"name": "БАЙОНЕТ | Токсин", "rarity": "rare", 
				"model": "bayonet", 
				"texture": "res://assets/skins/knife/bayonet_toxic.png", 
				"tint": Color.WHITE, "icon": Color(0.55, 1.0, 0.16, 1.0), 
			}, 
			"bayonet_gilded": {
				"name": "БАЙОНЕТ | Позолота", "rarity": "epic", 
				"model": "bayonet", 
				"texture": "res://assets/skins/knife/bayonet_gilded.png", 
				"tint": Color.WHITE, "icon": Color(0.79, 0.64, 0.15, 1.0), 
			}, 
			"karambit_ultraviolet": {
				"name": "КАРАМБИТ | Ультрафиолет", "rarity": "legendary", 
				"model": "karambit", 
				"texture": "res://assets/skins/knife/karambit_ultraviolet.png", 
				"tint": Color.WHITE, "icon": Color(0.63, 0.33, 0.95, 1.0), 
			}, 
			"karambit_crimson_night": {
				"name": "КАРАМБИТ | Багровая ночь", "rarity": "rare", 
				"model": "karambit", 
				"texture": "res://assets/skins/knife/karambit_crimson_night.png", 
				"tint": Color.WHITE, "icon": Color(0.88, 0.13, 0.19, 1.0), 
			}, 
			"karambit_glacier": {
				"name": "КАРАМБИТ | Ледник", "rarity": "common", 
				"model": "karambit", 
				"texture": "res://assets/skins/knife/karambit_glacier.png", 
				"tint": Color.WHITE, "icon": Color(0.72, 0.85, 0.94, 1.0), 
			}, 
			"karambit_toxic": {
				"name": "КАРАМБИТ | Токсин", "rarity": "rare", 
				"model": "karambit", 
				"texture": "res://assets/skins/knife/karambit_toxic.png", 
				"tint": Color.WHITE, "icon": Color(0.55, 1.0, 0.16, 1.0), 
			}, 
			"karambit_gilded": {
				"name": "КАРАМБИТ | Позолота", "rarity": "epic", 
				"model": "karambit", 
				"texture": "res://assets/skins/knife/karambit_gilded.png", 
				"tint": Color.WHITE, "icon": Color(0.79, 0.64, 0.15, 1.0), 
			}, 
			"skeleton_ultraviolet": {
				"name": "СКЕЛЕТ | Ультрафиолет", "rarity": "legendary", 
				"model": "skeleton", 
				"texture": "res://assets/skins/knife/skeleton_ultraviolet.png", 
				"tint": Color.WHITE, "icon": Color(0.63, 0.33, 0.95, 1.0), 
			}, 
			"skeleton_crimson_night": {
				"name": "СКЕЛЕТ | Багровая ночь", "rarity": "rare", 
				"model": "skeleton", 
				"texture": "res://assets/skins/knife/skeleton_crimson_night.png", 
				"tint": Color.WHITE, "icon": Color(0.88, 0.13, 0.19, 1.0), 
			}, 
			"skeleton_glacier": {
				"name": "СКЕЛЕТ | Ледник", "rarity": "common", 
				"model": "skeleton", 
				"texture": "res://assets/skins/knife/skeleton_glacier.png", 
				"tint": Color.WHITE, "icon": Color(0.72, 0.85, 0.94, 1.0), 
			}, 
			"skeleton_toxic": {
				"name": "СКЕЛЕТ | Токсин", "rarity": "rare", 
				"model": "skeleton", 
				"texture": "res://assets/skins/knife/skeleton_toxic.png", 
				"tint": Color.WHITE, "icon": Color(0.55, 1.0, 0.16, 1.0), 
			}, 
			"skeleton_gilded": {
				"name": "СКЕЛЕТ | Позолота", "rarity": "epic", 
				"model": "skeleton", 
				"texture": "res://assets/skins/knife/skeleton_gilded.png", 
				"tint": Color.WHITE, "icon": Color(0.79, 0.64, 0.15, 1.0), 
			}, 
			"dagger_ultraviolet": {
				"name": "КИНЖАЛЫ | Ультрафиолет", "rarity": "legendary", 
				"model": "dagger", 
				"texture": "res://assets/skins/knife/dagger_ultraviolet.png", 
				"tint": Color.WHITE, "icon": Color(0.63, 0.33, 0.95, 1.0), 
			}, 
			"dagger_crimson_night": {
				"name": "КИНЖАЛЫ | Багровая ночь", "rarity": "rare", 
				"model": "dagger", 
				"texture": "res://assets/skins/knife/dagger_crimson_night.png", 
				"tint": Color.WHITE, "icon": Color(0.88, 0.13, 0.19, 1.0), 
			}, 
			"dagger_glacier": {
				"name": "КИНЖАЛЫ | Ледник", "rarity": "common", 
				"model": "dagger", 
				"texture": "res://assets/skins/knife/dagger_glacier.png", 
				"tint": Color.WHITE, "icon": Color(0.72, 0.85, 0.94, 1.0), 
			}, 
			"dagger_toxic": {
				"name": "КИНЖАЛЫ | Токсин", "rarity": "rare", 
				"model": "dagger", 
				"texture": "res://assets/skins/knife/dagger_toxic.png", 
				"tint": Color.WHITE, "icon": Color(0.55, 1.0, 0.16, 1.0), 
			}, 
			"dagger_gilded": {
				"name": "КИНЖАЛЫ | Позолота", "rarity": "epic", 
				"model": "dagger", 
				"texture": "res://assets/skins/knife/dagger_gilded.png", 
				"tint": Color.WHITE, "icon": Color(0.79, 0.64, 0.15, 1.0), 
			}, 
			"combat_ultraviolet": {
				"name": "БОЕВОЙ НОЖ | Ультрафиолет", "rarity": "legendary", 
				"model": "combat", 
				"texture": "res://assets/skins/knife/combatknife_ultraviolet.png", 
				"tint": Color.WHITE, "icon": Color(0.63, 0.33, 0.95, 1.0), 
			}, 
			"combat_crimson_night": {
				"name": "БОЕВОЙ НОЖ | Багровая ночь", "rarity": "rare", 
				"model": "combat", 
				"texture": "res://assets/skins/knife/combatknife_crimson_night.png", 
				"tint": Color.WHITE, "icon": Color(0.88, 0.13, 0.19, 1.0), 
			}, 
			"combat_glacier": {
				"name": "БОЕВОЙ НОЖ | Ледник", "rarity": "common", 
				"model": "combat", 
				"texture": "res://assets/skins/knife/combatknife_glacier.png", 
				"tint": Color.WHITE, "icon": Color(0.72, 0.85, 0.94, 1.0), 
			}, 
			"combat_toxic": {
				"name": "БОЕВОЙ НОЖ | Токсин", "rarity": "rare", 
				"model": "combat", 
				"texture": "res://assets/skins/knife/combatknife_toxic.png", 
				"tint": Color.WHITE, "icon": Color(0.55, 1.0, 0.16, 1.0), 
			}, 
			"combat_gilded": {
				"name": "БОЕВОЙ НОЖ | Позолота", "rarity": "epic", 
				"model": "combat", 
				"texture": "res://assets/skins/knife/combatknife_gilded.png", 
				"tint": Color.WHITE, "icon": Color(0.79, 0.64, 0.15, 1.0), 
			}, 
			"nomad_ultraviolet": {
				"name": "НОМАД | Ультрафиолет", "rarity": "legendary", 
				"model": "nomad", 
				"texture": "res://assets/skins/knife/nomad_ultraviolet.png", 
				"tint": Color.WHITE, "icon": Color(0.63, 0.33, 0.95, 1.0), 
			}, 
			"nomad_crimson_night": {
				"name": "НОМАД | Багровая ночь", "rarity": "rare", 
				"model": "nomad", 
				"texture": "res://assets/skins/knife/nomad_crimson_night.png", 
				"tint": Color.WHITE, "icon": Color(0.88, 0.13, 0.19, 1.0), 
			}, 
			"nomad_glacier": {
				"name": "НОМАД | Ледник", "rarity": "common", 
				"model": "nomad", 
				"texture": "res://assets/skins/knife/nomad_glacier.png", 
				"tint": Color.WHITE, "icon": Color(0.72, 0.85, 0.94, 1.0), 
			}, 
			"nomad_toxic": {
				"name": "НОМАД | Токсин", "rarity": "rare", 
				"model": "nomad", 
				"texture": "res://assets/skins/knife/nomad_toxic.png", 
				"tint": Color.WHITE, "icon": Color(0.55, 1.0, 0.16, 1.0), 
			}, 
			"nomad_gilded": {
				"name": "НОМАД | Позолота", "rarity": "epic", 
				"model": "nomad", 
				"texture": "res://assets/skins/knife/nomad_gilded.png", 
				"tint": Color.WHITE, "icon": Color(0.79, 0.64, 0.15, 1.0), 
			}, 
		}, 
	}, 
}

const ITEMS: = [
	{"weapon": "awp", "skin": "default"}, 
	{"weapon": "ak47", "skin": "classic"}, 
	{"weapon": "m4a1", "skin": "steel"}, 
	{"weapon": "deagle", "skin": "chrome"}, 
	{"weapon": "usp", "skin": "stock"}, 
	{"weapon": "knife", "skin": "forest"}, 
	{"weapon": "knife", "skin": "lava"}, 
	{"weapon": "knife", "skin": "bayonet"}, 
	{"weapon": "knife", "skin": "karambit"}, 
	{"weapon": "knife", "skin": "skeleton"}, 
	{"weapon": "knife", "skin": "dagger"}, 
	{"weapon": "knife", "skin": "combat"}, 
	{"weapon": "knife", "skin": "nomad"}, 
	{"weapon": "awp", "skin": "asiimov"}, 
	{"weapon": "ak47", "skin": "vulcan"}, 
	{"weapon": "m4a1", "skin": "printstream"}, 
	{"weapon": "deagle", "skin": "blaze"}, 
	{"weapon": "usp", "skin": "noir"}, 
	{"weapon": "awp", "skin": "ultraviolet"}, 
	{"weapon": "awp", "skin": "crimson_night"}, 
	{"weapon": "awp", "skin": "glacier"}, 
	{"weapon": "awp", "skin": "toxic"}, 
	{"weapon": "awp", "skin": "gilded"}, 
	{"weapon": "ak47", "skin": "ultraviolet"}, 
	{"weapon": "ak47", "skin": "crimson_night"}, 
	{"weapon": "ak47", "skin": "glacier"}, 
	{"weapon": "ak47", "skin": "toxic"}, 
	{"weapon": "ak47", "skin": "gilded"}, 
	{"weapon": "m4a1", "skin": "ultraviolet"}, 
	{"weapon": "m4a1", "skin": "crimson_night"}, 
	{"weapon": "m4a1", "skin": "glacier"}, 
	{"weapon": "m4a1", "skin": "toxic"}, 
	{"weapon": "m4a1", "skin": "gilded"}, 
	{"weapon": "deagle", "skin": "ultraviolet"}, 
	{"weapon": "deagle", "skin": "crimson_night"}, 
	{"weapon": "deagle", "skin": "glacier"}, 
	{"weapon": "deagle", "skin": "toxic"}, 
	{"weapon": "deagle", "skin": "gilded"}, 
	{"weapon": "usp", "skin": "ultraviolet"}, 
	{"weapon": "usp", "skin": "crimson_night"}, 
	{"weapon": "usp", "skin": "glacier"}, 
	{"weapon": "usp", "skin": "toxic"}, 
	{"weapon": "usp", "skin": "gilded"}, 
	{"weapon": "knife", "skin": "butterfly_ultraviolet"}, 
	{"weapon": "knife", "skin": "butterfly_crimson_night"}, 
	{"weapon": "knife", "skin": "butterfly_glacier"}, 
	{"weapon": "knife", "skin": "butterfly_toxic"}, 
	{"weapon": "knife", "skin": "butterfly_gilded"}, 
	{"weapon": "knife", "skin": "bayonet_ultraviolet"}, 
	{"weapon": "knife", "skin": "bayonet_crimson_night"}, 
	{"weapon": "knife", "skin": "bayonet_glacier"}, 
	{"weapon": "knife", "skin": "bayonet_toxic"}, 
	{"weapon": "knife", "skin": "bayonet_gilded"}, 
	{"weapon": "knife", "skin": "karambit_ultraviolet"}, 
	{"weapon": "knife", "skin": "karambit_crimson_night"}, 
	{"weapon": "knife", "skin": "karambit_glacier"}, 
	{"weapon": "knife", "skin": "karambit_toxic"}, 
	{"weapon": "knife", "skin": "karambit_gilded"}, 
	{"weapon": "knife", "skin": "skeleton_ultraviolet"}, 
	{"weapon": "knife", "skin": "skeleton_crimson_night"}, 
	{"weapon": "knife", "skin": "skeleton_glacier"}, 
	{"weapon": "knife", "skin": "skeleton_toxic"}, 
	{"weapon": "knife", "skin": "skeleton_gilded"}, 
	{"weapon": "knife", "skin": "dagger_ultraviolet"}, 
	{"weapon": "knife", "skin": "dagger_crimson_night"}, 
	{"weapon": "knife", "skin": "dagger_glacier"}, 
	{"weapon": "knife", "skin": "dagger_toxic"}, 
	{"weapon": "knife", "skin": "dagger_gilded"}, 
	{"weapon": "knife", "skin": "combat_ultraviolet"}, 
	{"weapon": "knife", "skin": "combat_crimson_night"}, 
	{"weapon": "knife", "skin": "combat_glacier"}, 
	{"weapon": "knife", "skin": "combat_toxic"}, 
	{"weapon": "knife", "skin": "combat_gilded"}, 
	{"weapon": "knife", "skin": "nomad_ultraviolet"}, 
	{"weapon": "knife", "skin": "nomad_crimson_night"}, 
	{"weapon": "knife", "skin": "nomad_glacier"}, 
	{"weapon": "knife", "skin": "nomad_toxic"}, 
	{"weapon": "knife", "skin": "nomad_gilded"}, 
]


static func get_weapon(id: String) -> Dictionary:
	if WEAPONS.has(id):
		return WEAPONS[id]
	return WEAPONS["awp"]


static func get_skin(weapon_id: String, skin_id: String) -> Dictionary:
	var weapon: = get_weapon(weapon_id)
	var skins: Dictionary = weapon["skins"]
	if skins.has(skin_id):
		return skins[skin_id]
	return skins.values()[0]


static func get_item(weapon_id: String, skin_id: String) -> Dictionary:
	var weapon: = get_weapon(weapon_id)
	var skin: = get_skin(weapon_id, skin_id)
	return {
		"weapon_id": weapon_id, 
		"skin_id": skin_id, 
		"weapon": weapon, 
		"skin": skin, 
		"full_name": "%s | %s" % [weapon["name"], skin["name"]], 
	}


static func get_rarity(skin: Dictionary) -> Dictionary:
	var key: String = skin.get("rarity", "common")
	return RARITY.get(key, RARITY["common"])


static func is_melee(weapon_id: String) -> bool:
	return str(get_weapon(weapon_id).get("type", "")) == "knife"


static func type_label(weapon: Dictionary) -> String:
	match str(weapon.get("type", "")):
		"knife":
			return "НОЖ  ·  БЛИЖНИЙ БОЙ"
		"sniper":
			return "СНАЙПЕРСКАЯ  ·  ОДИН ВЫСТРЕЛ"
		"pistol":
			return "ПИСТОЛЕТ  ·  ПОЛУАВТО"
		"rifle":
			return "АВТОМАТИЧЕСКАЯ  ·  ОЧЕРЕДЬ"
		_:
			return "ПОЛУАВТО"
