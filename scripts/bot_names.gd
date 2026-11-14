extends RefCounted









const Data = preload("res://scripts/bot_name_data.gd")

const MAX_NICK_LENGTH: = 18
const RECENT_LIMIT: = 96
const MAX_ATTEMPTS: = 14


const NUMBER_TAGS: = [
	"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", 
	"01", "02", "03", "04", "05", "07", "08", "09", "10", "11", 
	"12", "13", "17", "21", "23", "33", "42", "47", "52", "66", 
	"69", "73", "77", "88", "99", "100", "101", "111", "123", "133", 
	"228", "321", "333", "420", "555", "666", "777", "888", "999", "1000", 
	"1337", "2000", "2001", "2002", "2003", "2004", "2005", "2006", "2007", "2008", 
	"2009", "2010", "2011", "2012", "2013", "2014", "2015", "2016", "2017", "2018", 
	"2019", "2020", "2021", "2022", "2023", "2024", "2025", "2026", "007", "148", 
]

var _rng: = RandomNumberGenerator.new()
var _recent: Array[String] = []


func _init() -> void :
	_rng.randomize()



func random_nick() -> String:
	var nick: = ""
	for _attempt in MAX_ATTEMPTS:
		nick = _fit(_build())
		if not _recent.has(nick):
			break
	if nick.is_empty():
		nick = "player%d" % _rng.randi_range(1, 999)
	_remember(nick)
	return nick


func _remember(nick: String) -> void :
	_recent.append(nick)
	if _recent.size() > RECENT_LIMIT:
		_recent.pop_front()


func _build() -> String:
	var roll: = _rng.randi_range(0, 99)
	var nick: = ""
	if roll < 26:
		nick = _word_number()
	elif roll < 44:
		nick = _single_word()
	elif roll < 56:
		nick = _compound()
	elif roll < 66:
		nick = _underscored()
	elif roll < 74:
		nick = _leet_word()
	elif roll < 81:
		nick = _wrapped()
	elif roll < 88:
		nick = _tagged()
	elif roll < 94:
		nick = _digits_only()
	elif roll < 97:
		nick = _name_number()
	elif roll < 99:
		nick = _two_words_number()
	else:
		nick = _the_word()
	return _maybe_leet(nick, roll)


func _maybe_leet(nick: String, roll: int) -> String:

	if roll >= 94:
		return nick
	if _rng.randf() >= 0.16:
		return nick
	return _leet(nick)


func _single_word() -> String:
	var word: = _word()
	if _rng.randf() < 0.08:
		word = "the" + _upper_first(word)
	return _cased(word)


func _word_number() -> String:
	var word: = _word()
	var roll: = _rng.randf()
	if roll < 0.18:
		return _number() + word
	if roll < 0.4:
		return word + "_" + _number()
	return word + _number()


func _compound() -> String:
	if _rng.randf() < 0.2:
		return _pick(Data.NOUNS) + _upper_first(_pick(Data.NOUNS))
	var adj: = _pick(Data.ADJECTIVES)
	var noun: = _pick(Data.NOUNS)
	if _rng.randf() < 0.35:
		return adj + _upper_first(noun)
	return adj + noun


func _underscored() -> String:
	var first: = _pick(Data.ADJECTIVES) if _rng.randf() < 0.55 else _word()
	var second: = _pick(Data.NOUNS)
	return first + "_" + second


func _leet_word() -> String:
	return _leet(_word())


func _wrapped() -> String:
	var core: = _word()
	if _rng.randf() < 0.45:
		core += _number()
	return "xX" + _upper_first(core) + "Xx"


func _tagged() -> String:
	var word: = _word()
	var tag: = _pick(Data.TAGS)
	var roll: = _rng.randf()
	if roll < 0.25:
		return tag + "_" + word
	if roll < 0.43:
		return word + tag
	return word + "_" + tag


func _digits_only() -> String:
	var roll: = _rng.randf()
	if roll < 0.38:
		var tag: = _number()
		while tag.length() < 3:
			tag = "0" + tag
		return tag
	if roll < 0.52:

		var digit: = str(_rng.randi_range(0, 9))
		var repeat: = ""
		for _i in _rng.randi_range(3, 8):
			repeat += digit
		return repeat
	var length: = _rng.randi_range(3, 8)
	var out: = ""
	for _i in length:
		out += str(_rng.randi_range(0, 9))
	return out


func _name_number() -> String:
	var list: Array = Data.NAMES if _rng.randf() < 0.7 else Data.RUSSIAN_NAMES
	return _pick(list) + _number()


func _two_words_number() -> String:
	var first: = _pick(Data.ADJECTIVES)
	var second: = _pick(Data.NOUNS)
	var core: = first + second if _rng.randf() < 0.5 else first + "_" + second
	return core + _number()


func _the_word() -> String:
	var nick: = "the" + _upper_first(_pick(Data.NOUNS))
	if _rng.randf() < 0.5:
		nick += _number()
	return nick


func _word() -> String:
	var list: Array = Data.LISTS[_rng.randi_range(0, Data.LISTS.size() - 1)]
	return _pick(list)


func _pick(list: Array) -> String:
	return str(list[_rng.randi_range(0, list.size() - 1)])


func _number() -> String:
	return str(NUMBER_TAGS[_rng.randi_range(0, NUMBER_TAGS.size() - 1)])


func _cased(word: String) -> String:
	var roll: = _rng.randf()
	if roll < 0.1:
		return word.to_upper()
	if roll < 0.28:
		return _upper_first(word)
	return word




func _upper_first(word: String) -> String:
	if word.is_empty():
		return word
	return word.substr(0, 1).to_upper() + word.substr(1)


func _leet(word: String) -> String:
	var replacements: = {
		"a": "4", "e": "3", "i": "1", "o": "0", 
		"s": "5", "t": "7", "g": "9", "b": "8", 
	}
	var out: = ""
	for i in word.length():
		var ch: = word.substr(i, 1)
		if replacements.has(ch) and _rng.randf() < 0.55:
			out += str(replacements[ch])
		else:
			out += ch
	return out


func _fit(nick: String) -> String:
	var out: = nick
	if out.length() > MAX_NICK_LENGTH:
		out = out.substr(0, MAX_NICK_LENGTH)
	while out.length() > 1 and (out.ends_with("_") or out.ends_with("-")):
		out = out.substr(0, out.length() - 1)
	return out
