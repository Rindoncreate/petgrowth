///|
test "same day weights retain numeric insertion order past nine records" {
  let weights : Array[@petgrowth.WeightEntry] = [
    { id: 10, date: "2026-10-17", grams: 4200, photo: "", },
    { id: 2, date: "2026-10-17", grams: 4100, photo: "", },
    { id: 11, date: "2026-10-16", grams: 4000, photo: "", },
  ]
  let journal = { ..@petgrowth.empty_journal(), weights, next_id: 12, }
  assert_eq(@petgrowth.weights_oldest_first(journal).map(entry => entry.id), [
    11, 2, 10,
  ])
  assert_eq(journal.weights.map(entry => entry.id), [10, 2, 11])
}

///|
test "same day diaries are newest first without mutating saved order" {
  let diaries : Array[@petgrowth.DiaryEntry] = [
    { id: 2, date: "2026-10-17", text: "morning", photo: "", },
    { id: 10, date: "2026-10-17", text: "evening", photo: "", },
    { id: 11, date: "2026-10-16", text: "yesterday", photo: "", },
  ]
  let journal = { ..@petgrowth.empty_journal(), diaries, next_id: 12, }
  assert_eq(@petgrowth.diaries_newest_first(journal).map(entry => entry.id), [
    10, 2, 11,
  ])
  assert_eq(journal.diaries.map(entry => entry.id), [2, 10, 11])
}
