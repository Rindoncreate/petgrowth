///|
pub(all) struct PetProfile {
  name : String
  birthday : String
  arrival_day : String
  avatar : String
} derive(Eq, ToJson, FromJson)

///|
pub extend PetProfile with Eq::{not_equal, equal}

///|
pub extend PetProfile with ToJson::{to_json}

///|
pub extend PetProfile with @json.FromJson::{from_json}

///|
pub(all) struct DiaryEntry {
  id : Int32
  date : String
  text : String
  photo : String
} derive(Eq, ToJson, FromJson)

///|
pub extend DiaryEntry with Eq::{not_equal, equal}

///|
pub extend DiaryEntry with ToJson::{to_json}

///|
pub extend DiaryEntry with @json.FromJson::{from_json}

///|
pub(all) struct WeightEntry {
  id : Int32
  date : String
  grams : Int32
  photo : String
} derive(Eq, ToJson, FromJson)

///|
pub extend WeightEntry with Eq::{not_equal, equal}

///|
pub extend WeightEntry with ToJson::{to_json}

///|
pub extend WeightEntry with @json.FromJson::{from_json}

///|
pub(all) struct Journal {
  pet : PetProfile
  diaries : Array[DiaryEntry]
  weights : Array[WeightEntry]
  next_id : Int32
  reminders_enabled : Bool
} derive(Eq, ToJson, FromJson)

///|
pub extend Journal with Eq::{not_equal, equal}

///|
pub extend Journal with ToJson::{to_json}

///|
pub extend Journal with @json.FromJson::{from_json}

///|
pub fn empty_journal() -> Journal {
  {
    pet: { name: "", birthday: "", arrival_day: "", avatar: "", },
    diaries: [],
    weights: [],
    next_id: 1,
    reminders_enabled: false,
  }
}

///|
pub fn decode_journal(raw : String) -> Journal {
  match try_decode_journal(raw) {
    Some(value) => value
    None => empty_journal()
  }
}

///|
pub fn try_decode_journal(raw : String) -> Journal? {
  try {
    let value : Journal = @json.from_json(@json.parse(raw))
    if !valid_journal(value) {
      None
    } else {
      Some(value)
    }
  } catch {
    _ => None
  }
}

///|
/// Validate imported records before replacing any saved data.
fn valid_journal(journal : Journal) -> Bool {
  if journal.next_id < 1 || journal.next_id >= 2147483647 {
    return false
  }
  for date in [journal.pet.birthday, journal.pet.arrival_day] {
    if date != "" && day_number(date) is None {
      return false
    }
  }
  if journal.pet.birthday != "" && journal.pet.arrival_day != "" &&
    journal.pet.birthday > journal.pet.arrival_day {
    return false
  }
  let ids : Map[Int32, Bool] = Map([])
  for entry in journal.diaries {
    if entry.id < 1 ||
      entry.id >= journal.next_id ||
      ids.contains(entry.id) ||
      day_number(entry.date) is None ||
      (entry.text.trim().length() == 0 && entry.photo.length() == 0) {
      return false
    }
    ids.set(entry.id, true)
  }
  for entry in journal.weights {
    if entry.id < 1 ||
      entry.id >= journal.next_id ||
      ids.contains(entry.id) ||
      day_number(entry.date) is None ||
      entry.grams <= 0 ||
      entry.grams > 200000 {
      return false
    }
    ids.set(entry.id, true)
  }
  true
}

///|
pub fn encode_journal(journal : Journal) -> String {
  journal.to_json().stringify()
}

///|
pub fn set_pet(
  journal : Journal,
  name : String,
  birthday : String,
  arrival_day : String,
) -> Journal {
  {
    ..journal,
    pet: { ..journal.pet, name: name.trim().to_owned(), birthday, arrival_day, },
  }
}

///|
/// Update a profile only when optional dates are valid and ordered.
pub fn try_set_pet(
  journal : Journal,
  name : String,
  birthday : String,
  arrival_day : String,
) -> Journal? {
  if name.trim().length() == 0 {
    return None
  }
  for date in [birthday, arrival_day] {
    if date != "" && day_number(date) is None {
      return None
    }
  }
  if birthday != "" && arrival_day != "" && birthday > arrival_day {
    return None
  }
  Some(set_pet(journal, name, birthday, arrival_day))
}

///|
pub fn set_avatar(journal : Journal, avatar : String) -> Journal {
  { ..journal, pet: { ..journal.pet, avatar, }, }
}

///|
pub fn set_reminders(journal : Journal, enabled : Bool) -> Journal {
  { ..journal, reminders_enabled: enabled, }
}

///|
pub fn add_diary(
  journal : Journal,
  date : String,
  text : String,
  photo : String,
) -> Journal? {
  if journal.next_id < 1 || journal.next_id >= 2147483646 {
    return None
  }
  let cleaned = text.trim().to_owned()
  if cleaned.length() == 0 && photo.length() == 0 {
    return None
  }
  if day_number(date) is None {
    return None
  }
  let diaries = journal.diaries.copy()
  diaries.push({ id: journal.next_id, date, text: cleaned, photo, })
  Some({ ..journal, diaries, next_id: journal.next_id + 1, })
}

///|
pub fn add_weight(
  journal : Journal,
  date : String,
  grams : Int32,
  photo : String,
) -> Journal? {
  if journal.next_id < 1 || journal.next_id >= 2147483646 {
    return None
  }
  if grams <= 0 || grams > 200000 || day_number(date) is None {
    return None
  }
  let weights = journal.weights.copy()
  weights.push({ id: journal.next_id, date, grams, photo, })
  Some({ ..journal, weights, next_id: journal.next_id + 1, })
}

///|
/// Parse kilograms as a positive decimal with at most three fractional digits.
/// Values outside 0.001–200 kg, signs and exponent notation are rejected.
pub fn parse_weight_kg(raw : String) -> Int32? {
  let text = raw.trim()
  let mut whole = 0
  let mut fraction = 0
  let mut whole_digits = 0
  let mut fraction_digits = 0
  let mut decimal = false
  for ch in text.iter() {
    if ch == '.' && !decimal && whole_digits > 0 {
      decimal = true
    } else if ch >= '0' && ch <= '9' {
      let digit = ch.to_int() - '0'.to_int()
      if decimal {
        fraction_digits += 1
        if fraction_digits > 3 {
          return None
        }
        fraction = fraction * 10 + digit
      } else {
        whole_digits += 1
        if whole_digits > 6 {
          return None
        }
        whole = whole * 10 + digit
        if whole > 200 {
          return None
        }
      }
    } else {
      return None
    }
  }
  if whole_digits == 0 || (decimal && fraction_digits == 0) {
    return None
  }
  let scale = match fraction_digits {
    1 => 100
    2 => 10
    _ => 1
  }
  let grams = whole * 1000 + fraction * scale
  if grams <= 0 || grams > 200000 {
    None
  } else {
    Some(grams)
  }
}

///|
pub fn format_grams_kg(grams : Int32) -> String {
  let whole = grams / 1000
  let fraction = grams % 1000
  let a = fraction / 100
  let b = fraction / 10 % 10
  let c = fraction % 10
  if fraction == 0 {
    "\{whole} kg"
  } else if c != 0 {
    "\{whole}.\{a}\{b}\{c} kg"
  } else if b != 0 {
    "\{whole}.\{a}\{b} kg"
  } else {
    "\{whole}.\{a} kg"
  }
}

///|
pub fn remove_diary(journal : Journal, id : Int32) -> Journal {
  { ..journal, diaries: journal.diaries.filter(entry => entry.id != id), }
}

///|
pub fn remove_weight(journal : Journal, id : Int32) -> Journal {
  { ..journal, weights: journal.weights.filter(entry => entry.id != id), }
}

///|
pub fn diaries_newest_first(journal : Journal) -> Array[DiaryEntry] {
  let result = journal.diaries.copy()
  result.sort_by((a, b) => {
    if a.date > b.date {
      -1
    } else if a.date < b.date {
      1
    } else {
      b.id - a.id
    }
  })
  result
}

///|
pub fn weights_oldest_first(journal : Journal) -> Array[WeightEntry] {
  let result = journal.weights.copy()
  result.sort_by((a, b) => {
    if a.date < b.date {
      -1
    } else if a.date > b.date {
      1
    } else if a.id < b.id {
      -1
    } else if a.id > b.id {
      1
    } else {
      0
    }
  })
  result
}

///|
pub fn latest_diary_gap(journal : Journal, today : String) -> Int32? {
  let today_number = match day_number(today) {
    Some(day) => day
    None => return None
  }
  let mut latest = -1
  for entry in journal.diaries {
    match day_number(entry.date) {
      Some(day) if day <= today_number && day > latest => latest = day
      _ => ()
    }
  }
  if latest == -1 {
    None
  } else {
    Some(today_number - latest)
  }
}

///|
pub fn reminder_text(
  journal : Journal,
  today : String,
  variant : Int32,
) -> String? {
  if !journal.reminders_enabled || journal.pet.name.length() == 0 {
    return None
  }
  let days = latest_diary_gap(journal, today)
  match days {
    Some(0) => None
    None =>
      Some("\{journal.pet.name} 在等你写下第一篇成长日记 📷")
    Some(n) if n >= 3 =>
      if variant % 2 == 0 {
        Some(
          "\{journal.pet.name}：我们已经 \{n} 天没留下新回忆啦。",
        )
      } else {
        Some(
          "今天的我也很可爱，来给 \{journal.pet.name} 留个小记录吧。",
        )
      }
    Some(_) =>
      Some("\{journal.pet.name} 想把今天的小事也收进相册。")
  }
}

///|
pub fn day_number(iso : String) -> Int32? {
  if iso.length() != 10 || iso[4:5] != "-" || iso[7:8] != "-" {
    return None
  }
  for index, ch in iso.iter2() {
    if index != 4 && index != 7 && (ch < '0' || ch > '9') {
      return None
    }
  }
  let year = @string.parse_int(iso[0:4]) catch { _ => return None }
  let month = @string.parse_int(iso[5:7]) catch { _ => return None }
  let day = @string.parse_int(iso[8:10]) catch { _ => return None }
  if year < 1 || month < 1 || month > 12 || day < 1 {
    return None
  }
  let leap = year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)
  let max_day = match month {
    2 => if leap { 29 } else { 28 }
    4 | 6 | 9 | 11 => 30
    _ => 31
  }
  if day > max_day {
    return None
  }
  let y = if month <= 2 { year - 1 } else { year }
  let era = y / 400
  let yoe = y - era * 400
  let mp = if month > 2 { month - 3 } else { month + 9 }
  let doy = (153 * mp + 2) / 5 + day - 1
  Some(era * 146097 + yoe * 365 + yoe / 4 - yoe / 100 + doy)
}
