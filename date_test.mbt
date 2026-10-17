///|
test "dates require exact unsigned ISO digits" {
  for
    invalid in [
      "+026-01-01", "2026-+1-01", "2026-01-+1", "2026- 1-01", "2026-01- 1", "0000-01-01",
      "2026-1-01", "2026-01-1", "2026/01/01", "2026-13-01", "2026-00-01", "2026-01-00",
      "2026-04-31", "1900-02-29", "2100-02-29", "not-a-date",
    ] {
    assert_eq(@petgrowth.day_number(invalid), None)
  }
}

///|
test "calendar boundaries keep consecutive day numbers" {
  for
    (before, after) in [
      ("2026-01-31", "2026-02-01"),
      ("2026-02-28", "2026-03-01"),
      ("2000-02-28", "2000-02-29"),
      ("2000-02-29", "2000-03-01"),
      ("2025-12-31", "2026-01-01"),
      ("0001-01-01", "0001-01-02"),
      ("9999-12-30", "9999-12-31"),
    ] {
    assert_eq(
      @petgrowth.day_number(after),
      @petgrowth.day_number(before).map(day => day + 1),
    )
  }
}
