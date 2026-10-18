///|
fn draft_model() -> Model {
  {
    journal: @petgrowth.empty_journal(),
    page: "home",
    date: "2026-10-18",
    diary_text: "早上吃饭以后精神不错",
    weight_text: "4.125",
    photo: "data:image/png;base64,AA==",
    name: "小橘",
    birthday: "",
    arrival_day: "",
    notice: "",
    demo: true,
    card_index: 2,
    growth_view: "timeline",
    modal: "diary",
    detail_id: 0,
    menu_open: false,
  }
}

///|
test "storage failure preserves the saved journal and unsaved draft" {
  let model = draft_model()
  let journal = @petgrowth.add_diary(
    model.journal,
    model.date,
    model.diary_text,
    model.photo,
  ).unwrap()
  let called = Ref(false)
  let result = commit_with(
    model,
    journal,
    "saved",
    saved => {
      called.val = true
      { ..saved, diary_text: "", photo: "", modal: "", demo: false, }
    },
    persist=_ => false,
  )
  assert_true(result.journal == model.journal)
  assert_eq(result.diary_text, model.diary_text)
  assert_eq(result.photo, model.photo)
  assert_eq(result.modal, "diary")
  assert_true(result.demo)
  assert_true(!called.val)
  assert_true(result.notice != "saved")
}

///|
test "successful persistence writes the candidate before dismissing the draft" {
  let model = draft_model()
  let journal = @petgrowth.add_diary(
    model.journal,
    model.date,
    model.diary_text,
    "",
  ).unwrap()
  let written = Ref("")
  let result = commit_with(
    model,
    journal,
    "saved",
    saved => {
      assert_true(written.val != "") catch {
        _ => abort("write must happen first")
      }
      { ..saved, diary_text: "", modal: "", demo: false, }
    },
    persist=raw => {
      written.val = raw
      true
    },
  )
  assert_true(@petgrowth.try_decode_journal(written.val) == Some(journal))
  assert_true(result.journal == journal)
  assert_eq(result.notice, "saved")
  assert_eq(result.diary_text, "")
  assert_eq(result.modal, "")
  assert_true(!result.demo)
}
