///|
fn commit_with(
  model : Model,
  journal : @petgrowth.Journal,
  success : String,
  on_success : (Model) -> Model,
  persist~ : (String) -> Bool = save_saved,
) -> Model {
  if persist(@petgrowth.encode_journal(journal)) {
    on_success({ ..model, journal, notice: success, })
  } else {
    {
      ..model,
      notice: "未能保存，请检查浏览器存储或导出备份；本次输入已保留。",
    }
  }
}

///|
fn commit(
  model : Model,
  journal : @petgrowth.Journal,
  success : String,
) -> Model {
  commit_with(model, journal, success, saved => saved)
}
