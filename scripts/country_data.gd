extends RefCounted










const COUNTRIES: = [

	{"code": "RU", "name": "РОССИЯ", "type": "h", "colors": [
		Color(0.96, 0.96, 0.96), Color(0.16, 0.32, 0.66), Color(0.82, 0.16, 0.18)]}, 
	{"code": "BY", "name": "БЕЛАРУСЬ", "type": "h", "colors": [
		Color(0.8, 0.15, 0.17), Color(0.2, 0.55, 0.24)], "weights": [2, 1]}, 
	{"code": "KZ", "name": "КАЗАХСТАН", "type": "sunrays", "colors": [
		Color(0.24, 0.6, 0.86), Color(1.0, 0.8, 0.25)]}, 
	{"code": "UA", "name": "УКРАИНА", "type": "h", "colors": [
		Color(0.24, 0.47, 0.78), Color(0.98, 0.8, 0.2)]}, 
	{"code": "AM", "name": "АРМЕНИЯ", "type": "h", "colors": [
		Color(0.85, 0.18, 0.2), Color(0.16, 0.32, 0.66), Color(0.95, 0.62, 0.16)]}, 
	{"code": "AZ", "name": "АЗЕРБАЙДЖАН", "type": "h", "colors": [
		Color(0.16, 0.55, 0.78), Color(0.82, 0.14, 0.18), Color(0.18, 0.62, 0.32)]}, 
	{"code": "GE", "name": "ГРУЗИЯ", "type": "cross", "colors": [
		Color(0.97, 0.97, 0.95), Color(0.84, 0.12, 0.14)]}, 
	{"code": "MD", "name": "МОЛДОВА", "type": "v", "colors": [
		Color(0.2, 0.36, 0.7), Color(0.98, 0.82, 0.2), Color(0.8, 0.14, 0.16)]}, 


	{"code": "DE", "name": "ГЕРМАНИЯ", "type": "h", "colors": [
		Color(0.13, 0.13, 0.13), Color(0.84, 0.14, 0.15), Color(1.0, 0.78, 0.16)]}, 
	{"code": "FR", "name": "ФРАНЦИЯ", "type": "v", "colors": [
		Color(0.12, 0.26, 0.6), Color(0.97, 0.97, 0.95), Color(0.84, 0.14, 0.16)]}, 
	{"code": "IT", "name": "ИТАЛИЯ", "type": "v", "colors": [
		Color(0.16, 0.58, 0.28), Color(0.97, 0.97, 0.95), Color(0.82, 0.14, 0.15)]}, 
	{"code": "ES", "name": "ИСПАНИЯ", "type": "h", "colors": [
		Color(0.8, 0.13, 0.16), Color(1.0, 0.8, 0.16), Color(0.8, 0.13, 0.16)], 
		"weights": [1, 2, 1]}, 
	{"code": "PT", "name": "ПОРТУГАЛИЯ", "type": "pt", "colors": [
		Color(0.12, 0.52, 0.25), Color(0.82, 0.12, 0.15), Color(1.0, 0.8, 0.2)]}, 
	{"code": "GB", "name": "ВЕЛИКОБРИТАНИЯ", "type": "uk", "colors": [
		Color(0.1, 0.18, 0.48), Color(0.97, 0.97, 0.97), Color(0.82, 0.12, 0.16)]}, 
	{"code": "IE", "name": "ИРЛАНДИЯ", "type": "v", "colors": [
		Color(0.12, 0.55, 0.32), Color(0.97, 0.97, 0.95), Color(0.95, 0.55, 0.15)]}, 
	{"code": "NL", "name": "НИДЕРЛАНДЫ", "type": "h", "colors": [
		Color(0.82, 0.14, 0.17), Color(0.97, 0.97, 0.95), Color(0.12, 0.3, 0.62)]}, 
	{"code": "BE", "name": "БЕЛЬГИЯ", "type": "v", "colors": [
		Color(0.12, 0.12, 0.12), Color(1.0, 0.82, 0.16), Color(0.82, 0.14, 0.16)]}, 
	{"code": "LU", "name": "ЛЮКСЕМБУРГ", "type": "h", "colors": [
		Color(0.86, 0.15, 0.17), Color(0.97, 0.97, 0.95), Color(0.32, 0.62, 0.86)]}, 
	{"code": "CH", "name": "ШВЕЙЦАРИЯ", "type": "cross", "colors": [
		Color(0.84, 0.12, 0.14), Color(0.98, 0.98, 0.96)]}, 
	{"code": "AT", "name": "АВСТРИЯ", "type": "h", "colors": [
		Color(0.86, 0.15, 0.17), Color(0.97, 0.97, 0.95), Color(0.86, 0.15, 0.17)]}, 
	{"code": "PL", "name": "ПОЛЬША", "type": "h", "colors": [
		Color(0.97, 0.97, 0.95), Color(0.84, 0.14, 0.16)]}, 
	{"code": "CZ", "name": "ЧЕХИЯ", "type": "cz", "colors": [
		Color(0.97, 0.97, 0.95), Color(0.82, 0.14, 0.16), Color(0.1, 0.24, 0.55)]}, 
	{"code": "SK", "name": "СЛОВАКИЯ", "type": "h", "colors": [
		Color(0.97, 0.97, 0.95), Color(0.12, 0.3, 0.62), Color(0.82, 0.14, 0.16)]}, 
	{"code": "HU", "name": "ВЕНГРИЯ", "type": "h", "colors": [
		Color(0.82, 0.14, 0.16), Color(0.97, 0.97, 0.95), Color(0.18, 0.55, 0.28)]}, 
	{"code": "RO", "name": "РУМЫНИЯ", "type": "v", "colors": [
		Color(0.1, 0.24, 0.6), Color(1.0, 0.82, 0.16), Color(0.82, 0.14, 0.16)]}, 
	{"code": "BG", "name": "БОЛГАРИЯ", "type": "h", "colors": [
		Color(0.97, 0.97, 0.95), Color(0.16, 0.55, 0.28), Color(0.82, 0.14, 0.16)]}, 
	{"code": "RS", "name": "СЕРБИЯ", "type": "h", "colors": [
		Color(0.82, 0.13, 0.15), Color(0.12, 0.28, 0.62), Color(0.97, 0.97, 0.95)]}, 
	{"code": "HR", "name": "ХОРВАТИЯ", "type": "h", "colors": [
		Color(0.82, 0.13, 0.15), Color(0.97, 0.97, 0.95), Color(0.12, 0.28, 0.62)]}, 
	{"code": "SI", "name": "СЛОВЕНИЯ", "type": "h", "colors": [
		Color(0.97, 0.97, 0.95), Color(0.12, 0.28, 0.62), Color(0.82, 0.13, 0.15)]}, 
	{"code": "GR", "name": "ГРЕЦИЯ", "type": "gr", "colors": [
		Color(0.12, 0.32, 0.66), Color(0.97, 0.97, 0.95)]}, 
	{"code": "SE", "name": "ШВЕЦИЯ", "type": "nordic", "colors": [
		Color(0.1, 0.32, 0.64), Color(1.0, 0.82, 0.16)]}, 
	{"code": "NO", "name": "НОРВЕГИЯ", "type": "nordic", "colors": [
		Color(0.82, 0.12, 0.15), Color(0.1, 0.24, 0.58), Color(0.97, 0.97, 0.95)]}, 
	{"code": "DK", "name": "ДАНИЯ", "type": "nordic", "colors": [
		Color(0.82, 0.12, 0.15), Color(0.97, 0.97, 0.95)]}, 
	{"code": "FI", "name": "ФИНЛЯНДИЯ", "type": "nordic", "colors": [
		Color(0.97, 0.97, 0.95), Color(0.12, 0.32, 0.66)]}, 
	{"code": "IS", "name": "ИСЛАНДИЯ", "type": "nordic", "colors": [
		Color(0.1, 0.3, 0.6), Color(0.82, 0.12, 0.15), Color(0.97, 0.97, 0.95)]}, 
	{"code": "EE", "name": "ЭСТОНИЯ", "type": "h", "colors": [
		Color(0.16, 0.38, 0.68), Color(0.1, 0.1, 0.12), Color(0.97, 0.97, 0.95)]}, 
	{"code": "LV", "name": "ЛАТВИЯ", "type": "h", "colors": [
		Color(0.55, 0.08, 0.12), Color(0.97, 0.97, 0.95), Color(0.55, 0.08, 0.12)], 
		"weights": [2, 1, 2]}, 
	{"code": "LT", "name": "ЛИТВА", "type": "h", "colors": [
		Color(1.0, 0.8, 0.16), Color(0.16, 0.55, 0.28), Color(0.82, 0.13, 0.15)]}, 
	{"code": "AL", "name": "АЛБАНИЯ", "type": "al", "colors": [
		Color(0.82, 0.12, 0.15), Color(0.1, 0.1, 0.12)]}, 
	{"code": "BA", "name": "БОСНИЯ И ГЕРЦЕГОВИНА", "type": "ba", "colors": [
		Color(0.1, 0.24, 0.58), Color(1.0, 0.8, 0.16), Color(0.97, 0.97, 0.95)]}, 
	{"code": "ME", "name": "ЧЕРНОГОРИЯ", "type": "me", "colors": [
		Color(0.78, 0.12, 0.14), Color(1.0, 0.8, 0.22)]}, 
	{"code": "MK", "name": "СЕВЕРНАЯ МАКЕДОНИЯ", "type": "mk", "colors": [
		Color(0.82, 0.12, 0.15), Color(1.0, 0.78, 0.16)]}, 
	{"code": "MT", "name": "МАЛЬТА", "type": "mt", "colors": [
		Color(0.97, 0.97, 0.95), Color(0.82, 0.12, 0.14), 
		Color(0.62, 0.64, 0.66)]}, 
	{"code": "CY", "name": "КИПР", "type": "cy", "colors": [
		Color(0.97, 0.97, 0.95), Color(0.8, 0.52, 0.2), 
		Color(0.2, 0.52, 0.26)]}, 
	{"code": "AD", "name": "АНДОРРА", "type": "v", "colors": [
		Color(0.1, 0.24, 0.58), Color(1.0, 0.82, 0.16), 
		Color(0.82, 0.12, 0.15)]}, 
	{"code": "MC", "name": "МОНАКО", "type": "h", "colors": [
		Color(0.82, 0.12, 0.15), Color(0.97, 0.97, 0.95)]}, 
	{"code": "SM", "name": "САН-МАРИНО", "type": "h", "colors": [
		Color(0.97, 0.97, 0.95), Color(0.55, 0.72, 0.88)]}, 
	{"code": "LI", "name": "ЛИХТЕНШТЕЙН", "type": "h", "colors": [
		Color(0.1, 0.24, 0.58), Color(0.82, 0.12, 0.15)]}, 
	{"code": "XK", "name": "КОСОВО", "type": "xk", "colors": [
		Color(0.1, 0.24, 0.58), Color(1.0, 0.8, 0.24), 
		Color(0.97, 0.97, 0.95)]}, 


	{"code": "US", "name": "США", "type": "us", "colors": [
		Color(0.82, 0.12, 0.16), Color(0.97, 0.97, 0.97), Color(0.1, 0.2, 0.5)]}, 
	{"code": "CA", "name": "КАНАДА", "type": "ca", "colors": [
		Color(0.84, 0.12, 0.15), Color(0.97, 0.97, 0.95)]}, 
	{"code": "MX", "name": "МЕКСИКА", "type": "v", "colors": [
		Color(0.1, 0.52, 0.28), Color(0.97, 0.97, 0.95), Color(0.82, 0.13, 0.15)]}, 
	{"code": "BR", "name": "БРАЗИЛИЯ", "type": "br", "colors": [
		Color(0.1, 0.55, 0.26), Color(1.0, 0.82, 0.16), Color(0.1, 0.24, 0.6)]}, 
	{"code": "AR", "name": "АРГЕНТИНА", "type": "ar", "colors": [
		Color(0.42, 0.68, 0.86), Color(0.97, 0.97, 0.95), Color(1.0, 0.78, 0.16)]}, 
	{"code": "CL", "name": "ЧИЛИ", "type": "cl", "colors": [
		Color(0.97, 0.97, 0.95), Color(0.82, 0.13, 0.15), Color(0.1, 0.26, 0.58)]}, 
	{"code": "PE", "name": "ПЕРУ", "type": "v", "colors": [
		Color(0.82, 0.12, 0.15), Color(0.97, 0.97, 0.95), 
		Color(0.82, 0.12, 0.15)]}, 
	{"code": "CO", "name": "КОЛУМБИЯ", "type": "h", "colors": [
		Color(1.0, 0.8, 0.16), Color(0.1, 0.24, 0.58), 
		Color(0.82, 0.12, 0.15)], "weights": [2, 1, 1]}, 
	{"code": "VE", "name": "ВЕНЕСУЭЛА", "type": "ve", "colors": [
		Color(1.0, 0.8, 0.16), Color(0.1, 0.24, 0.58), 
		Color(0.82, 0.12, 0.15), Color(0.97, 0.97, 0.95)]}, 
	{"code": "EC", "name": "ЭКВАДОР", "type": "ec", "colors": [
		Color(1.0, 0.8, 0.16), Color(0.1, 0.24, 0.58), 
		Color(0.82, 0.12, 0.15), Color(0.32, 0.25, 0.18)]}, 
	{"code": "BO", "name": "БОЛИВИЯ", "type": "h", "colors": [
		Color(0.82, 0.12, 0.15), Color(1.0, 0.8, 0.16), 
		Color(0.16, 0.52, 0.24)]}, 
	{"code": "PY", "name": "ПАРАГВАЙ", "type": "h", "colors": [
		Color(0.82, 0.12, 0.15), Color(0.97, 0.97, 0.95), 
		Color(0.1, 0.24, 0.58)]}, 
	{"code": "UY", "name": "УРУГВАЙ", "type": "uy", "colors": [
		Color(0.97, 0.97, 0.95), Color(0.1, 0.32, 0.64), 
		Color(0.97, 0.97, 0.95), Color(1.0, 0.78, 0.18)]}, 
	{"code": "CR", "name": "КОСТА-РИКА", "type": "h", "colors": [
		Color(0.1, 0.24, 0.58), Color(0.97, 0.97, 0.95), 
		Color(0.82, 0.12, 0.15), Color(0.97, 0.97, 0.95), 
		Color(0.1, 0.24, 0.58)], "weights": [1, 1, 2, 1, 1]}, 
	{"code": "PA", "name": "ПАНАМА", "type": "pa", "colors": [
		Color(0.97, 0.97, 0.95), Color(0.82, 0.12, 0.15), 
		Color(0.1, 0.24, 0.58), Color(0.97, 0.97, 0.95)]}, 
	{"code": "GT", "name": "ГВАТЕМАЛА", "type": "v", "colors": [
		Color(0.36, 0.64, 0.86), Color(0.97, 0.97, 0.95), 
		Color(0.36, 0.64, 0.86)]}, 
	{"code": "SV", "name": "САЛЬВАДОР", "type": "h", "colors": [
		Color(0.1, 0.32, 0.64), Color(0.97, 0.97, 0.95), 
		Color(0.1, 0.32, 0.64)]}, 
	{"code": "HN", "name": "ГОНДУРАС", "type": "h", "colors": [
		Color(0.36, 0.64, 0.86), Color(0.97, 0.97, 0.95), 
		Color(0.36, 0.64, 0.86)]}, 
	{"code": "NI", "name": "НИКАРАГУА", "type": "h", "colors": [
		Color(0.1, 0.32, 0.64), Color(0.97, 0.97, 0.95), 
		Color(0.1, 0.32, 0.64)]}, 
	{"code": "DO", "name": "ДОМИНИКАНА", "type": "do", "colors": [
		Color(0.1, 0.24, 0.58), Color(0.82, 0.12, 0.15), 
		Color(0.97, 0.97, 0.95)]}, 
	{"code": "CU", "name": "КУБА", "type": "cu", "colors": [
		Color(0.1, 0.24, 0.58), Color(0.97, 0.97, 0.95), 
		Color(0.82, 0.12, 0.15), Color(0.97, 0.97, 0.95)]}, 
	{"code": "JM", "name": "ЯМАЙКА", "type": "jm", "colors": [
		Color(0.1, 0.52, 0.24), Color(0.1, 0.1, 0.12), 
		Color(1.0, 0.8, 0.16)]}, 
	{"code": "TT", "name": "ТРИНИДАД И ТОБАГО", "type": "diag", "colors": [
		Color(0.82, 0.12, 0.15), Color(0.1, 0.1, 0.12), 
		Color(0.97, 0.97, 0.95)]}, 
	{"code": "BB", "name": "БАРБАДОС", "type": "bb", "colors": [
		Color(0.1, 0.24, 0.58), Color(1.0, 0.8, 0.16), 
		Color(0.1, 0.1, 0.12)]}, 
	{"code": "BS", "name": "БАГАМЫ", "type": "bs", "colors": [
		Color(0.1, 0.6, 0.72), Color(1.0, 0.8, 0.16), 
		Color(0.1, 0.1, 0.12)]}, 
	{"code": "BZ", "name": "БЕЛИЗ", "type": "bz", "colors": [
		Color(0.1, 0.32, 0.64), Color(0.82, 0.12, 0.15), 
		Color(0.97, 0.97, 0.95), Color(0.16, 0.55, 0.26)]}, 
	{"code": "HT", "name": "ГАИТИ", "type": "h", "colors": [
		Color(0.1, 0.24, 0.58), Color(0.82, 0.12, 0.15)]}, 


	{"code": "JP", "name": "ЯПОНИЯ", "type": "sun", "colors": [
		Color(0.97, 0.97, 0.95), Color(0.82, 0.12, 0.15)]}, 
	{"code": "CN", "name": "КИТАЙ", "type": "cn", "colors": [
		Color(0.82, 0.12, 0.15), Color(1.0, 0.82, 0.16)]}, 
	{"code": "IN", "name": "ИНДИЯ", "type": "in", "colors": [
		Color(1.0, 0.6, 0.16), Color(0.97, 0.97, 0.95), Color(0.12, 0.5, 0.22), 
		Color(0.1, 0.24, 0.58)]}, 
	{"code": "TR", "name": "ТУРЦИЯ", "type": "tr", "colors": [
		Color(0.82, 0.12, 0.15), Color(0.97, 0.97, 0.95)]}, 
	{"code": "IL", "name": "ИЗРАИЛЬ", "type": "il", "colors": [
		Color(0.97, 0.97, 0.95), Color(0.1, 0.25, 0.58)]}, 
	{"code": "AE", "name": "ОАЭ", "type": "ae", "colors": [
		Color(0.82, 0.13, 0.15), Color(0.12, 0.55, 0.26), Color(0.97, 0.97, 0.95), 
		Color(0.1, 0.1, 0.12)]}, 
	{"code": "PH", "name": "ФИЛИППИНЫ", "type": "ph", "colors": [
		Color(0.1, 0.24, 0.58), Color(0.82, 0.13, 0.15), Color(0.97, 0.97, 0.95), 
		Color(1.0, 0.82, 0.16)]}, 
	{"code": "ID", "name": "ИНДОНЕЗИЯ", "type": "h", "colors": [
		Color(0.82, 0.12, 0.15), Color(0.97, 0.97, 0.95)]}, 
	{"code": "TH", "name": "ТАИЛАНД", "type": "h", "colors": [
		Color(0.82, 0.12, 0.15), Color(0.97, 0.97, 0.95), Color(0.1, 0.22, 0.5), 
		Color(0.97, 0.97, 0.95), Color(0.82, 0.12, 0.15)], "weights": [1, 1, 2, 1, 1]}, 
	{"code": "VN", "name": "ВЬЕТНАМ", "type": "solid", "colors": [
		Color(0.82, 0.12, 0.15), Color(1.0, 0.82, 0.16)]}, 
	{"code": "SA", "name": "САУДОВСКАЯ АРАВИЯ", "type": "sa", "colors": [
		Color(0.1, 0.52, 0.28), Color(0.97, 0.97, 0.95)]}, 
	{"code": "KR", "name": "ЮЖНАЯ КОРЕЯ", "type": "kr", "colors": [
		Color(0.97, 0.97, 0.95), Color(0.82, 0.12, 0.15), 
		Color(0.1, 0.24, 0.58)]}, 
	{"code": "TW", "name": "ТАЙВАНЬ", "type": "tw", "colors": [
		Color(0.82, 0.12, 0.15), Color(0.1, 0.24, 0.58), 
		Color(0.97, 0.97, 0.95)]}, 
	{"code": "HK", "name": "ГОНКОНГ", "type": "hk", "colors": [
		Color(0.82, 0.12, 0.15), Color(0.97, 0.97, 0.95)]}, 
	{"code": "SG", "name": "СИНГАПУР", "type": "sg", "colors": [
		Color(0.82, 0.12, 0.15), Color(0.97, 0.97, 0.95)]}, 
	{"code": "MY", "name": "МАЛАЙЗИЯ", "type": "my", "colors": [
		Color(0.82, 0.12, 0.15), Color(0.97, 0.97, 0.95), 
		Color(0.1, 0.24, 0.58), Color(1.0, 0.8, 0.16)]}, 
	{"code": "PK", "name": "ПАКИСТАН", "type": "pk", "colors": [
		Color(0.1, 0.45, 0.25), Color(0.97, 0.97, 0.95)]}, 
	{"code": "BD", "name": "БАНГЛАДЕШ", "type": "bd", "colors": [
		Color(0.1, 0.48, 0.26), Color(0.82, 0.12, 0.15)]}, 
	{"code": "LK", "name": "ШРИ-ЛАНКА", "type": "lk", "colors": [
		Color(1.0, 0.78, 0.16), Color(0.52, 0.12, 0.2), 
		Color(0.9, 0.55, 0.16), Color(0.14, 0.42, 0.24)]}, 
	{"code": "NP", "name": "НЕПАЛ", "type": "np", "colors": [
		Color(0.1, 0.24, 0.58), Color(0.78, 0.1, 0.16)]}, 
	{"code": "MM", "name": "МЬЯНМА", "type": "hstar", "colors": [
		Color(1.0, 0.8, 0.16), Color(0.12, 0.52, 0.26), 
		Color(0.82, 0.12, 0.15), Color(0.97, 0.97, 0.95)]}, 
	{"code": "KH", "name": "КАМБОДЖА", "type": "kh", "colors": [
		Color(0.1, 0.24, 0.58), Color(0.82, 0.12, 0.15), 
		Color(0.97, 0.97, 0.95)]}, 
	{"code": "LA", "name": "ЛАОС", "type": "la", "colors": [
		Color(0.82, 0.12, 0.15), Color(0.1, 0.24, 0.58), 
		Color(0.97, 0.97, 0.95)]}, 
	{"code": "MN", "name": "МОНГОЛИЯ", "type": "mn", "colors": [
		Color(0.82, 0.12, 0.15), Color(0.1, 0.24, 0.58), 
		Color(1.0, 0.8, 0.16)]}, 
	{"code": "UZ", "name": "УЗБЕКИСТАН", "type": "uz", "colors": [
		Color(0.1, 0.45, 0.78), Color(0.97, 0.97, 0.95), 
		Color(0.12, 0.52, 0.26), Color(0.82, 0.12, 0.15)]}, 
	{"code": "KG", "name": "КЫРГЫЗСТАН", "type": "sunrays", "colors": [
		Color(0.82, 0.12, 0.15), Color(1.0, 0.8, 0.16)]}, 
	{"code": "TJ", "name": "ТАДЖИКИСТАН", "type": "tj", "colors": [
		Color(0.82, 0.12, 0.15), Color(0.97, 0.97, 0.95), 
		Color(0.12, 0.52, 0.26), Color(1.0, 0.78, 0.16)]}, 
	{"code": "TM", "name": "ТУРКМЕНИСТАН", "type": "tm", "colors": [
		Color(0.1, 0.48, 0.26), Color(0.82, 0.12, 0.15), 
		Color(0.97, 0.97, 0.95), Color(0.97, 0.97, 0.95)]}, 
	{"code": "AF", "name": "АФГАНИСТАН", "type": "af", "colors": [
		Color(0.97, 0.97, 0.95), Color(0.1, 0.1, 0.12)]}, 
	{"code": "IR", "name": "ИРАН", "type": "ir", "colors": [
		Color(0.12, 0.52, 0.26), Color(0.97, 0.97, 0.95), 
		Color(0.82, 0.12, 0.15)]}, 
	{"code": "IQ", "name": "ИРАК", "type": "iq", "colors": [
		Color(0.82, 0.12, 0.15), Color(0.97, 0.97, 0.95), 
		Color(0.1, 0.1, 0.12), Color(0.12, 0.52, 0.26)]}, 
	{"code": "SY", "name": "СИРИЯ", "type": "sy", "colors": [
		Color(0.82, 0.12, 0.15), Color(0.97, 0.97, 0.95), 
		Color(0.1, 0.1, 0.12), Color(0.12, 0.52, 0.26)]}, 
	{"code": "JO", "name": "ИОРДАНИЯ", "type": "tri", "colors": [
		Color(0.1, 0.1, 0.12), Color(0.97, 0.97, 0.95), 
		Color(0.12, 0.48, 0.26), Color(0.82, 0.12, 0.15), 
		Color(0.97, 0.97, 0.95)]}, 
	{"code": "LB", "name": "ЛИВАН", "type": "lb", "colors": [
		Color(0.82, 0.12, 0.15), Color(0.97, 0.97, 0.95), 
		Color(0.12, 0.5, 0.26)]}, 
	{"code": "OM", "name": "ОМАН", "type": "ae", "colors": [
		Color(0.82, 0.12, 0.15), Color(0.97, 0.97, 0.95), 
		Color(0.82, 0.12, 0.15), Color(0.12, 0.5, 0.26)]}, 
	{"code": "QA", "name": "КАТАР", "type": "serrated", "colors": [
		Color(0.97, 0.97, 0.95), Color(0.52, 0.1, 0.2)]}, 
	{"code": "BH", "name": "БАХРЕЙН", "type": "serrated", "colors": [
		Color(0.97, 0.97, 0.95), Color(0.82, 0.12, 0.15)]}, 
	{"code": "YE", "name": "ЙЕМЕН", "type": "h", "colors": [
		Color(0.82, 0.12, 0.15), Color(0.97, 0.97, 0.95), 
		Color(0.1, 0.1, 0.12)]}, 
	{"code": "PS", "name": "ПАЛЕСТИНА", "type": "tri", "colors": [
		Color(0.1, 0.1, 0.12), Color(0.97, 0.97, 0.95), 
		Color(0.12, 0.48, 0.26), Color(0.82, 0.12, 0.15)]}, 
	{"code": "BN", "name": "БРУНЕЙ", "type": "bn", "colors": [
		Color(1.0, 0.82, 0.16), Color(0.1, 0.1, 0.12), 
		Color(0.97, 0.97, 0.95), Color(0.82, 0.12, 0.15)]}, 
	{"code": "TL", "name": "ТИМОР-ЛЕСТЕ", "type": "tl", "colors": [
		Color(0.82, 0.12, 0.15), Color(1.0, 0.8, 0.16), 
		Color(0.1, 0.1, 0.12), Color(0.97, 0.97, 0.95)]}, 
	{"code": "MV", "name": "МАЛЬДИВЫ", "type": "mv", "colors": [
		Color(0.82, 0.12, 0.15), Color(0.1, 0.5, 0.26), 
		Color(0.97, 0.97, 0.95)]}, 
	{"code": "BT", "name": "БУТАН", "type": "bt", "colors": [
		Color(1.0, 0.8, 0.16), Color(1.0, 0.55, 0.12), 
		Color(0.97, 0.97, 0.95)]}, 


	{"code": "EG", "name": "ЕГИПЕТ", "type": "h", "colors": [
		Color(0.82, 0.13, 0.15), Color(0.97, 0.97, 0.95), Color(0.1, 0.1, 0.12)]}, 
	{"code": "NG", "name": "НИГЕРИЯ", "type": "v", "colors": [
		Color(0.1, 0.52, 0.28), Color(0.97, 0.97, 0.95), Color(0.1, 0.52, 0.28)]}, 
	{"code": "KE", "name": "КЕНИЯ", "type": "h", "colors": [
		Color(0.1, 0.1, 0.1), Color(0.82, 0.13, 0.15), Color(0.1, 0.5, 0.25)]}, 
	{"code": "ET", "name": "ЭФИОПИЯ", "type": "h", "colors": [
		Color(0.12, 0.52, 0.28), Color(1.0, 0.82, 0.16), Color(0.82, 0.13, 0.15)]}, 
	{"code": "MA", "name": "МАРОККО", "type": "ma", "colors": [
		Color(0.82, 0.12, 0.15), Color(0.12, 0.5, 0.26)]}, 
	{"code": "DZ", "name": "АЛЖИР", "type": "crescent_split", "colors": [
		Color(0.1, 0.5, 0.26), Color(0.97, 0.97, 0.95), 
		Color(0.82, 0.12, 0.15)]}, 
	{"code": "TN", "name": "ТУНИС", "type": "crescent_disc", "colors": [
		Color(0.82, 0.12, 0.15), Color(0.97, 0.97, 0.95), 
		Color(0.82, 0.12, 0.15)]}, 
	{"code": "LY", "name": "ЛИВИЯ", "type": "h", "colors": [
		Color(0.82, 0.12, 0.15), Color(0.1, 0.1, 0.12), 
		Color(0.12, 0.5, 0.26)]}, 
	{"code": "SD", "name": "СУДАН", "type": "tri", "colors": [
		Color(0.82, 0.12, 0.15), Color(0.97, 0.97, 0.95), 
		Color(0.1, 0.1, 0.12), Color(0.12, 0.5, 0.26)]}, 
	{"code": "SS", "name": "ЮЖНЫЙ СУДАН", "type": "tri", "colors": [
		Color(0.1, 0.1, 0.12), Color(0.82, 0.12, 0.15), 
		Color(0.12, 0.5, 0.26), Color(0.1, 0.24, 0.58), 
		Color(1.0, 0.8, 0.16)]}, 
	{"code": "GH", "name": "ГАНА", "type": "hstar", "colors": [
		Color(0.82, 0.12, 0.15), Color(1.0, 0.8, 0.16), 
		Color(0.12, 0.5, 0.26), Color(0.1, 0.1, 0.12)]}, 
	{"code": "SN", "name": "СЕНЕГАЛ", "type": "vstar", "colors": [
		Color(0.1, 0.5, 0.26), Color(1.0, 0.8, 0.16), 
		Color(0.82, 0.12, 0.15), Color(0.1, 0.5, 0.26)]}, 
	{"code": "CI", "name": "КОТ-Д'ИВУАР", "type": "v", "colors": [
		Color(1.0, 0.55, 0.12), Color(0.97, 0.97, 0.95), 
		Color(0.12, 0.5, 0.26)]}, 
	{"code": "CM", "name": "КАМЕРУН", "type": "vstar", "colors": [
		Color(0.12, 0.5, 0.26), Color(0.82, 0.12, 0.15), 
		Color(1.0, 0.8, 0.16), Color(1.0, 0.8, 0.16)]}, 
	{"code": "UG", "name": "УГАНДА", "type": "ug", "colors": [
		Color(0.1, 0.1, 0.12), Color(1.0, 0.8, 0.16), 
		Color(0.82, 0.12, 0.15), Color(0.97, 0.97, 0.95)]}, 
	{"code": "TZ", "name": "ТАНЗАНИЯ", "type": "diag", "colors": [
		Color(0.12, 0.5, 0.26), Color(0.1, 0.32, 0.64), 
		Color(0.1, 0.1, 0.12), Color(1.0, 0.8, 0.16)]}, 
	{"code": "ZW", "name": "ЗИМБАБВЕ", "type": "zw", "colors": [
		Color(0.12, 0.5, 0.26), Color(1.0, 0.8, 0.16), 
		Color(0.82, 0.12, 0.15), Color(0.1, 0.1, 0.12), 
		Color(0.82, 0.12, 0.15)]}, 
	{"code": "ZM", "name": "ЗАМБИЯ", "type": "zm", "colors": [
		Color(0.12, 0.5, 0.26), Color(0.82, 0.12, 0.15), 
		Color(0.1, 0.1, 0.12), Color(1.0, 0.62, 0.14)]}, 
	{"code": "MZ", "name": "МОЗАМБИК", "type": "mz", "colors": [
		Color(0.12, 0.5, 0.26), Color(0.1, 0.1, 0.12), 
		Color(1.0, 0.8, 0.16), Color(0.97, 0.97, 0.95), 
		Color(0.82, 0.12, 0.15)]}, 
	{"code": "AO", "name": "АНГОЛА", "type": "ao", "colors": [
		Color(0.82, 0.12, 0.15), Color(0.1, 0.1, 0.12), 
		Color(1.0, 0.8, 0.16)]}, 
	{"code": "NA", "name": "НАМИБИЯ", "type": "na", "colors": [
		Color(0.1, 0.32, 0.64), Color(0.12, 0.5, 0.26), 
		Color(0.82, 0.12, 0.15), Color(0.97, 0.97, 0.95), 
		Color(1.0, 0.8, 0.16)]}, 
	{"code": "BW", "name": "БОТСВАНА", "type": "h", "colors": [
		Color(0.42, 0.68, 0.86), Color(0.97, 0.97, 0.95), 
		Color(0.1, 0.1, 0.12), Color(0.97, 0.97, 0.95), 
		Color(0.42, 0.68, 0.86)], "weights": [2, 1, 3, 1, 2]}, 
	{"code": "RW", "name": "РУАНДА", "type": "rw", "colors": [
		Color(0.24, 0.6, 0.86), Color(1.0, 0.8, 0.16), 
		Color(0.12, 0.5, 0.26), Color(1.0, 0.8, 0.16)]}, 
	{"code": "SO", "name": "СОМАЛИ", "type": "hstar", "colors": [
		Color(0.24, 0.6, 0.86), Color(0.97, 0.97, 0.95)]}, 
	{"code": "ML", "name": "МАЛИ", "type": "v", "colors": [
		Color(0.12, 0.5, 0.26), Color(1.0, 0.8, 0.16), 
		Color(0.82, 0.12, 0.15)]}, 
	{"code": "BF", "name": "БУРКИНА-ФАСО", "type": "hstar", "colors": [
		Color(0.82, 0.12, 0.15), Color(0.12, 0.5, 0.26), 
		Color(1.0, 0.8, 0.16)]}, 
	{"code": "NE", "name": "НИГЕР", "type": "ne", "colors": [
		Color(1.0, 0.55, 0.12), Color(0.97, 0.97, 0.95), 
		Color(0.12, 0.5, 0.26), Color(1.0, 0.55, 0.12)]}, 
	{"code": "TD", "name": "ЧАД", "type": "v", "colors": [
		Color(0.1, 0.24, 0.58), Color(1.0, 0.8, 0.16), 
		Color(0.82, 0.12, 0.15)]}, 
	{"code": "CG", "name": "КОНГО", "type": "diag", "colors": [
		Color(0.12, 0.5, 0.26), Color(0.82, 0.12, 0.15), 
		Color(1.0, 0.8, 0.16), Color(1.0, 0.8, 0.16)]}, 
	{"code": "CD", "name": "ДР КОНГО", "type": "cd", "colors": [
		Color(0.24, 0.6, 0.86), Color(1.0, 0.8, 0.16), 
		Color(0.82, 0.12, 0.15)]}, 
	{"code": "MU", "name": "МАВРИКИЙ", "type": "h", "colors": [
		Color(0.82, 0.12, 0.15), Color(0.1, 0.24, 0.58), 
		Color(1.0, 0.8, 0.16), Color(0.12, 0.5, 0.26)]}, 
	{"code": "MG", "name": "МАДАГАСКАР", "type": "v", "colors": [
		Color(0.97, 0.97, 0.95), Color(0.82, 0.12, 0.15), 
		Color(0.12, 0.5, 0.26)]}, 
	{"code": "GM", "name": "ГАМБИЯ", "type": "h", "colors": [
		Color(0.82, 0.12, 0.15), Color(0.97, 0.97, 0.95), 
		Color(0.1, 0.24, 0.58), Color(0.97, 0.97, 0.95), 
		Color(0.12, 0.5, 0.26)], "weights": [2, 1, 2, 1, 2]}, 
	{"code": "BJ", "name": "БЕНИН", "type": "h", "colors": [
		Color(0.12, 0.5, 0.26), Color(1.0, 0.8, 0.16), 
		Color(0.82, 0.12, 0.15)], "weights": [2, 1, 1]}, 
	{"code": "TG", "name": "ТОГО", "type": "hstar", "colors": [
		Color(0.12, 0.5, 0.26), Color(1.0, 0.8, 0.16), 
		Color(0.82, 0.12, 0.15), Color(1.0, 0.8, 0.16), 
		Color(0.97, 0.97, 0.95)]}, 
	{"code": "GN", "name": "ГВИНЕЯ", "type": "v", "colors": [
		Color(0.82, 0.12, 0.15), Color(1.0, 0.8, 0.16), 
		Color(0.12, 0.5, 0.26)]}, 
	{"code": "SL", "name": "СЬЕРРА-ЛЕОНЕ", "type": "h", "colors": [
		Color(0.12, 0.5, 0.26), Color(0.97, 0.97, 0.95), 
		Color(0.24, 0.6, 0.86)]}, 
	{"code": "LR", "name": "ЛИБЕРИЯ", "type": "hstar", "colors": [
		Color(0.82, 0.12, 0.15), Color(0.97, 0.97, 0.95), 
		Color(0.1, 0.24, 0.58), Color(0.97, 0.97, 0.95)]}, 
	{"code": "MR", "name": "МАВРИТАНИЯ", "type": "crescent", "colors": [
		Color(0.12, 0.5, 0.26), Color(1.0, 0.8, 0.16)]}, 
	{"code": "ER", "name": "ЭРИТРЕЯ", "type": "tri", "colors": [
		Color(0.12, 0.5, 0.26), Color(0.12, 0.5, 0.26), 
		Color(0.24, 0.6, 0.86), Color(0.82, 0.12, 0.15), 
		Color(1.0, 0.8, 0.16)]}, 
	{"code": "DJ", "name": "ДЖИБУТИ", "type": "tri", "colors": [
		Color(0.42, 0.68, 0.86), Color(0.42, 0.68, 0.86), 
		Color(0.12, 0.5, 0.26), Color(0.97, 0.97, 0.95), 
		Color(0.82, 0.12, 0.15)]}, 
	{"code": "GA", "name": "ГАБОН", "type": "h", "colors": [
		Color(0.12, 0.5, 0.26), Color(1.0, 0.8, 0.16), 
		Color(0.1, 0.24, 0.58)]}, 
	{"code": "GQ", "name": "ЭКВ. ГВИНЕЯ", "type": "tri", "colors": [
		Color(0.12, 0.5, 0.26), Color(0.97, 0.97, 0.95), 
		Color(0.82, 0.12, 0.15), Color(0.24, 0.6, 0.86)]}, 
	{"code": "MW", "name": "МАЛАВИ", "type": "h", "colors": [
		Color(0.1, 0.1, 0.12), Color(0.82, 0.12, 0.15), 
		Color(0.12, 0.5, 0.26)]}, 
	{"code": "LS", "name": "ЛЕСОТО", "type": "h", "colors": [
		Color(0.1, 0.24, 0.58), Color(0.97, 0.97, 0.95), 
		Color(0.12, 0.5, 0.26)]}, 
	{"code": "SZ", "name": "ЭСВАТИНИ", "type": "h", "colors": [
		Color(0.1, 0.24, 0.58), Color(1.0, 0.8, 0.16), 
		Color(0.82, 0.12, 0.15), Color(1.0, 0.8, 0.16), 
		Color(0.1, 0.24, 0.58)], "weights": [2, 1, 3, 1, 2]}, 
	{"code": "GW", "name": "ГВИНЕЯ-БИСАУ", "type": "hstar", "colors": [
		Color(0.82, 0.12, 0.15), Color(1.0, 0.8, 0.16), 
		Color(0.12, 0.5, 0.26), Color(0.1, 0.1, 0.12)]}, 
	{"code": "CV", "name": "КАБО-ВЕРДЕ", "type": "h", "colors": [
		Color(0.1, 0.24, 0.58), Color(0.97, 0.97, 0.95), 
		Color(0.1, 0.24, 0.58), Color(0.97, 0.97, 0.95), 
		Color(0.82, 0.12, 0.15)], "weights": [2, 1, 1, 1, 2]}, 


	{"code": "AU", "name": "АВСТРАЛИЯ", "type": "au", "colors": [
		Color(0.1, 0.18, 0.48)]}, 
	{"code": "NZ", "name": "НОВАЯ ЗЕЛАНДИЯ", "type": "nz", "colors": [
		Color(0.1, 0.18, 0.48)]}, 
	{"code": "FJ", "name": "ФИДЖИ", "type": "fj", "colors": [
		Color(0.42, 0.68, 0.86)]}, 
	{"code": "PG", "name": "ПАПУА — НОВАЯ ГВИНЕЯ", "type": "pg", "colors": [
		Color(0.82, 0.12, 0.15), Color(0.1, 0.1, 0.12), 
		Color(0.97, 0.97, 0.95), Color(1.0, 0.8, 0.16)]}, 
	{"code": "WS", "name": "САМОА", "type": "ws", "colors": [
		Color(0.82, 0.12, 0.15), Color(0.1, 0.24, 0.58), 
		Color(0.97, 0.97, 0.95)]}, 
	{"code": "TO", "name": "ТОНГА", "type": "to", "colors": [
		Color(0.82, 0.12, 0.15), Color(0.97, 0.97, 0.95), 
		Color(0.82, 0.12, 0.15)]}, 
	{"code": "VU", "name": "ВАНУАТУ", "type": "vu", "colors": [
		Color(0.82, 0.12, 0.15), Color(0.12, 0.5, 0.26), 
		Color(0.1, 0.1, 0.12), Color(1.0, 0.8, 0.16)]}, 


	{"code": "XX", "name": "ДРУГАЯ СТРАНА", "type": "globe", "colors": []}, 
]


static func get_country(code: String) -> Dictionary:
	for entry in COUNTRIES:
		if str(entry["code"]) == code:
			return entry
	return COUNTRIES[COUNTRIES.size() - 1]


static func index_of(code: String) -> int:
	for i in COUNTRIES.size():
		if str(COUNTRIES[i]["code"]) == code:
			return i
	return COUNTRIES.size() - 1


static func code_at(index: int) -> String:
	return str(COUNTRIES[clampi(index, 0, COUNTRIES.size() - 1)]["code"])


static func name_at(index: int) -> String:
	return str(COUNTRIES[clampi(index, 0, COUNTRIES.size() - 1)]["name"])




static func label_at(index: int) -> String:
	var entry: Dictionary = COUNTRIES[clampi(index, 0, COUNTRIES.size() - 1)]
	return "%s  ·  %s" % [str(entry["name"]), str(entry["code"])]
