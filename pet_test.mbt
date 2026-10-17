///|
test "valid dates and leap years" {
  assert_true(@petgrowth.day_number("2024-02-29") is Some(_))
  assert_true(@petgrowth.day_number("2025-02-29") is None)
  let first = @petgrowth.day_number("2026-10-16")
  let second = @petgrowth.day_number("2026-10-17")
  assert_eq(second, first.map(day => day + 1))
}

///|
test "journals sort and reminders follow actual records" {
  let state = @petgrowth.set_pet(
    @petgrowth.empty_journal(),
    "豆包",
    "2026-01-01",
    "2026-02-01",
  )
  let state = match
    @petgrowth.add_diary(state, "2026-10-12", "跑到桌上了", "") {
    Some(value) => value
    None => fail("first entry should be valid")
  }
  let state = match
    @petgrowth.add_diary(state, "2026-10-15", "又学会了握手", "") {
    Some(value) => value
    None => fail("second entry should be valid")
  }
  assert_eq(@petgrowth.diaries_newest_first(state)[0].date, "2026-10-15")
  assert_eq(@petgrowth.latest_diary_gap(state, "2026-10-17"), Some(2))
  let enabled = { ..state, reminders_enabled: true, }
  assert_true(@petgrowth.reminder_text(enabled, "2026-10-17", 1) is Some(_))
  assert_true(@petgrowth.reminder_text(enabled, "2026-10-15", 1) is None)
}

///|
test "weight rejects invalid values and survives json roundtrip" {
  let state = @petgrowth.empty_journal()
  assert_true(@petgrowth.add_weight(state, "2026-10-17", 0, "") is None)
  let state = match @petgrowth.add_weight(state, "2026-10-17", 4200, "") {
    Some(value) => value
    None => fail("weight should be valid")
  }
  let copy = @petgrowth.decode_journal(@petgrowth.encode_journal(state))
  assert_eq(copy.weights[0].grams, 4200)
  assert_eq(copy.next_id, 2)
  assert_eq(@petgrowth.format_grams_kg(4250), "4.25 kg")
  assert_eq(@petgrowth.format_grams_kg(4050), "4.05 kg")
}
