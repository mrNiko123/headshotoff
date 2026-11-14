extends RefCounted














const MAGIC: = "GDSH"
const VERSION: = 1
const SHORT_MAGIC: = "G2"
const SHORT_VERSION: = 2


const MAX_PAYLOAD_BYTES: = 4 * 1024 * 1024

const KIND_CROSSHAIR: = "crosshair"
const KIND_COLORS: = "colors"
const KIND_UI: = "ui"
const KIND_HANDS: = "hands"

const KIND_LETTERS: = {
	KIND_CROSSHAIR: "c", 
	KIND_COLORS: "o", 
	KIND_UI: "u", 
	KIND_HANDS: "h", 
}
const LETTER_KINDS: = {
	"c": KIND_CROSSHAIR, 
	"o": KIND_COLORS, 
	"u": KIND_UI, 
	"h": KIND_HANDS, 
}




static func encode(kind: String, text: String) -> String:
	var raw: = text.to_utf8_buffer()
	if raw.is_empty():
		return ""
	var packed: = raw.compress(FileAccess.COMPRESSION_DEFLATE)
	if packed.is_empty():
		return ""
	var letter: String = KIND_LETTERS.get(kind, "")
	if letter.is_empty():
		return ""
	return "%s%s:%s" % [SHORT_MAGIC, letter, _base64_trim(packed)]









static func decode(code: String, expected_kind: = "") -> Dictionary:
	var cleaned: = code.strip_edges()
	if cleaned.is_empty():
		return _fail("Код пустой.")
	if cleaned.substr(0, SHORT_MAGIC.length()).to_upper() == SHORT_MAGIC:
		return _decode_short(cleaned, expected_kind)
	return _decode_legacy(cleaned, expected_kind)


static func _decode_short(code: String, expected_kind: String) -> Dictionary:
	var kind_letter: = code.substr(SHORT_MAGIC.length(), 1).to_lower()
	var kind: String = LETTER_KINDS.get(kind_letter, "")
	if kind.is_empty():
		return _fail("Неизвестный вид CFG-кода.")
	var colon: = code.find(":")
	if colon != SHORT_MAGIC.length() + 1:
		return _fail("Повреждён заголовок CFG-кода.")
	if not expected_kind.is_empty() and kind != expected_kind:
		return _fail("Код предназначен для другого раздела.")
	var body: = _strip_spaces(code.substr(colon + 1))
	if body.is_empty():
		return _fail("В коде нет данных.")
	var packed: = Marshalls.base64_to_raw(_base64_pad(body))
	if packed.is_empty():
		return _fail("Код повреждён: не читается base64.")
	var raw: = packed.decompress_dynamic(MAX_PAYLOAD_BYTES, 
		FileAccess.COMPRESSION_DEFLATE)
	if raw.is_empty():
		return _fail("Код повреждён: не распаковывается.")
	return {
		"ok": true, 
		"error": "", 
		"kind": kind, 
		"version": SHORT_VERSION, 
		"text": raw.get_string_from_utf8(), 
	}


static func _decode_legacy(code: String, expected_kind: String) -> Dictionary:
	var colon: = code.find(":")
	if colon <= 0:
		return _fail("Это не CFG-код HEADSHOT.")
	var header: = code.substr(0, colon)
	var body: = _strip_spaces(code.substr(colon + 1))
	var parts: = header.split("-", false)
	if parts.size() != 3 or parts[0] != MAGIC:
		return _fail("Это не CFG-код HEADSHOT.")
	var kind: = parts[1].to_lower()
	var version: = int(parts[2])
	if version != VERSION:
		return _fail("Версия кода не поддерживается: %d." % version)
	if not expected_kind.is_empty() and kind != expected_kind:
		return _fail("Код предназначен для другого раздела.")
	if body.is_empty():
		return _fail("В коде нет данных.")
	var packed: = Marshalls.base64_to_raw(_base64_pad(body))
	if packed.is_empty():
		return _fail("Код повреждён: не читается base64.")
	var raw: = packed.decompress_dynamic(MAX_PAYLOAD_BYTES, 
		FileAccess.COMPRESSION_GZIP)
	if raw.is_empty():
		return _fail("Код повреждён: не распаковывается.")
	return {
		"ok": true, 
		"error": "", 
		"kind": kind, 
		"version": version, 
		"text": raw.get_string_from_utf8(), 
	}





static func _base64_trim(packed: PackedByteArray) -> String:
	var encoded: = Marshalls.raw_to_base64(packed)\
	.replace("+", "-").replace("/", "_")
	while encoded.ends_with("="):
		encoded = encoded.substr(0, encoded.length() - 1)
	return encoded


static func _base64_pad(body: String) -> String:
	var normalized: = body.replace("-", "+").replace("_", "/")
	var remainder: = normalized.length() % 4
	if remainder == 0:
		return normalized
	if remainder == 2:
		return normalized + "=="
	if remainder == 3:
		return normalized + "="
	return ""


static func _strip_spaces(value: String) -> String:
	return value.replace("\r", "").replace("\n", "").replace("\t", "")\
	.replace(" ", "")


static func _fail(message: String) -> Dictionary:
	return {
		"ok": false, 
		"error": message, 
		"kind": "", 
		"version": 0, 
		"text": "", 
	}
