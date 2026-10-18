///|
test "diaries need valid dates and either text or a photo" {
  let base = @petgrowth.empty_journal()
  assert_true(@petgrowth.add_diary(base, "2026-10-18", "  ", "") is None)
  assert_true(
    @petgrowth.add_diary(base, "bad-date", "有精神了", "") is None,
  )
  let photo_only = @petgrowth.add_diary(
    base, "2026-10-18", "  ", "data:image/png;base64,AA==",
  ).unwrap()
  assert_eq(photo_only.diaries[0].text, "")
  assert_eq(photo_only.next_id, 2)
  assert_eq(base.diaries.length(), 0)
}

///|
test "deletion is scoped to the selected record and does not reuse identifiers" {
  let base = @petgrowth.empty_journal()
  let first = @petgrowth.add_diary(base, "2026-10-18", "早上的记录", "").unwrap()
  let both = @petgrowth.add_weight(first, "2026-10-18", 4000, "").unwrap()
  let removed = @petgrowth.remove_diary(both, 1)
  assert_eq(removed.diaries.length(), 0)
  assert_eq(removed.weights.length(), 1)
  assert_eq(removed.next_id, 3)
  assert_eq(both.diaries.length(), 1)
  assert_true(@petgrowth.remove_weight(removed, 999) == removed)
  assert_eq(@petgrowth.remove_weight(removed, 2).weights.length(), 0)
  let added = @petgrowth.add_diary(removed, "2026-10-18", "晚上的记录", "").unwrap()
  assert_eq(added.diaries[0].id, 3)
}

///|
test "reminders respect opt out profile and invalid dates" {
  let base = @petgrowth.empty_journal()
  assert_true(@petgrowth.reminder_text(base, "2026-10-18", 0) is None)
  let enabled = @petgrowth.set_reminders(base, true)
  assert_true(@petgrowth.reminder_text(enabled, "2026-10-18", 0) is None)
  let named = @petgrowth.set_pet(enabled, "小橘", "", "")
  assert_true(@petgrowth.reminder_text(named, "2026-10-18", 0) is Some(_))
  assert_true(@petgrowth.reminder_text(named, "invalid", 0) is None)
  assert_true(
    @petgrowth.reminder_text(
      @petgrowth.set_reminders(named, false),
      "2026-10-18",
      0,
    )
    is None,
  )
}

///|
test "reminder gaps use the latest non future diary and both long gap variants" {
  let base = @petgrowth.set_reminders(
    @petgrowth.set_pet(@petgrowth.empty_journal(), "小橘", "", ""),
    true,
  )
  let past = @petgrowth.add_diary(base, "2026-10-15", "过去的记录", "").unwrap()
  let journal = @petgrowth.add_diary(past, "2026-10-20", "预约记录", "").unwrap()
  assert_eq(@petgrowth.latest_diary_gap(journal, "2026-10-18"), Some(3))
  assert_true(@petgrowth.reminder_text(journal, "2026-10-18", 0) is Some(_))
  assert_true(@petgrowth.reminder_text(journal, "2026-10-18", 1) is Some(_))
  assert_true(
    @petgrowth.reminder_text(journal, "2026-10-18", 0) !=
    @petgrowth.reminder_text(journal, "2026-10-18", 1),
  )
  assert_true(@petgrowth.reminder_text(journal, "2026-10-15", 0) is None)
  assert_true(@petgrowth.reminder_text(journal, "2026-10-16", 0) is Some(_))
}
