///|
test "profile accepts unknown dates and trims pet names" {
  let base = @petgrowth.empty_journal()
  let saved = @petgrowth.try_set_pet(base, " 小橘 ", "", "").unwrap()
  assert_eq(saved.pet.name, "小橘")
  assert_eq(base.pet.name, "")
  assert_true(
    @petgrowth.try_set_pet(base, "小橘", "2026-01-01", "2026-02-01")
    is Some(_),
  )
}

///|
test "profile rejects invalid dates and arrival before birth" {
  let base = @petgrowth.empty_journal()
  assert_true(@petgrowth.try_set_pet(base, "  ", "", "") is None)
  assert_true(@petgrowth.try_set_pet(base, "小橘", "2026-02-30", "") is None)
  assert_true(@petgrowth.try_set_pet(base, "小橘", "", "2026-13-01") is None)
  assert_true(
    @petgrowth.try_set_pet(base, "小橘", "2026-02-01", "2026-01-01") is None,
  )
}
