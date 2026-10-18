///|
fn main {
  let journal = @petgrowth.try_set_pet(
    @petgrowth.empty_journal(),
    "小橘",
    "2025-06-01",
    "2025-08-01",
  ).unwrap()
  let journal = @petgrowth.add_diary(
    journal, "2026-10-15", "早上喂食后精神不错，玩了逗猫棒。", "",
  ).unwrap()
  let journal = @petgrowth.add_diary(
    journal, "2026-10-15", "晚上食欲正常，记下今天的小事。", "",
  ).unwrap()
  let first = @petgrowth.parse_weight_kg("4.125").unwrap()
  let second = @petgrowth.parse_weight_kg("4.200").unwrap()
  let journal = @petgrowth.add_weight(journal, "2026-10-14", first, "").unwrap()
  let journal = @petgrowth.add_weight(journal, "2026-10-15", second, "").unwrap()
  let journal = @petgrowth.set_reminders(journal, true)
  let backup = @petgrowth.encode_journal(journal)
  let restored = @petgrowth.try_decode_journal(backup).unwrap()
  println("Pet: \{restored.pet.name}")
  println("Diaries: \{restored.diaries.length()}")
  for entry in @petgrowth.weights_oldest_first(restored) {
    println("\{entry.date}: \{@petgrowth.format_grams_kg(entry.grams)}")
  }
  println("Backup roundtrip: \{restored == journal}")
  println(
    @petgrowth.reminder_text(restored, "2026-10-18", 0).unwrap_or("No reminder"),
  )
}
