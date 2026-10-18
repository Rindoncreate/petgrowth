///|
fn assert_backup_eq(
  actual : @petgrowth.Journal?,
  expected : @petgrowth.Journal?,
) -> Unit raise {
  assert_true(actual == expected)
}

///|
test "backup decoder rejects malformed data and unsafe counters" {
  for raw in ["", "{", "null", "[]", "{}", "{\"next_id\":1}"] {
    assert_true(@petgrowth.try_decode_journal(raw) is None)
  }
  let empty = @petgrowth.empty_journal()
  assert_backup_eq(
    @petgrowth.try_decode_journal(@petgrowth.encode_journal(empty)),
    Some(empty),
  )
  for counter in [0, -1, 2147483647] {
    let bad = { ..empty, next_id: counter, }
    assert_backup_eq(
      @petgrowth.try_decode_journal(@petgrowth.encode_journal(bad)),
      None,
    )
  }
  let exhausted = { ..empty, next_id: 2147483646, }
  assert_backup_eq(
    @petgrowth.add_diary(exhausted, "2026-10-18", "note", ""),
    None,
  )
  assert_backup_eq(
    @petgrowth.add_weight(exhausted, "2026-10-18", 4200, ""),
    None,
  )
}

///|
test "backup decoder rejects invalid records instead of silently accepting them" {
  let base = @petgrowth.empty_journal()
  let entry : @petgrowth.WeightEntry = {
    id: 1,
    date: "2026-10-18",
    grams: 4200,
    photo: "",
  }
  let good = { ..base, weights: [entry], next_id: 2, }
  assert_backup_eq(
    @petgrowth.try_decode_journal(@petgrowth.encode_journal(good)),
    Some(good),
  )
  for
    bad in [
      { ..good, weights: [entry, entry], },
      { ..good, next_id: 1, },
      { ..good, weights: [{ ..entry, id: 0, }], },
      { ..good, weights: [{ ..entry, date: "2026-02-30", }], },
      { ..good, weights: [{ ..entry, grams: 0, }], },
      { ..good, weights: [{ ..entry, grams: 200001, }], },
      {
        ..good,
        diaries: [{ id: 1, date: "2026-10-18", text: "same id", photo: "", }],
      },
      {
        ..base,
        diaries: [{ id: 1, date: "2026-10-18", text: "   ", photo: "", }],
        next_id: 2,
      },
      { ..base, pet: { ..base.pet, birthday: "2026-02-30", }, },
    ] {
    assert_backup_eq(
      @petgrowth.try_decode_journal(@petgrowth.encode_journal(bad)),
      None,
    )
  }
}

///|
test "backup roundtrip preserves unicode and transparent image data" {
  let base = @petgrowth.set_pet(
    @petgrowth.empty_journal(),
    "小猫🐈",
    "2025-06-01",
    "",
  )
  let journal = {
    ..base,
    diaries: [
      {
        id: 1,
        date: "2026-10-18",
        text: "早上\n喂药后有精神了",
        photo: "data:image/png;base64,AA==",
      },
    ],
    weights: [{ id: 2, date: "2026-10-18", grams: 4125, photo: "", }],
    next_id: 3,
  }
  assert_backup_eq(
    @petgrowth.try_decode_journal(@petgrowth.encode_journal(journal)),
    Some(journal),
  )
}
