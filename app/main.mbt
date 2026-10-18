///|
pub struct Model {
  journal : @petgrowth.Journal
  page : String
  date : String
  diary_text : String
  weight_text : String
  photo : String
  name : String
  birthday : String
  arrival_day : String
  notice : String
  demo : Bool
  card_index : Int32
  growth_view : String
  modal : String
  detail_id : Int32
  menu_open : Bool
} derive(Eq)

///|
pub extend Model with Eq::{not_equal, equal}

///|
priv enum Msg {
  Page(String)
  Date(String)
  DiaryText(String)
  WeightText(String)
  Name(String)
  Birthday(String)
  ArrivalDay(String)
  PickPhoto
  PhotoReady(String)
  PickAvatar
  AvatarReady(String)
  SavePet
  SaveDiary
  SaveWeight
  DeleteDiary(Int32)
  DeleteWeight(Int32)
  ToggleReminder
  ExportBackup
  ImportBackup
  BackupReady(String)
  SelectCard(Int32)
  StepCard(Int32)
  GrowthView(String)
  OpenComposer(String)
  CloseModal
  OpenDiary(Int32)
  OpenWeight(Int32)
  ToggleMenu
  ToggleDemo
}

///|
extern "js" fn load_saved() -> String = "() => localStorage.getItem('petgrowth-v1') || ''"

///|
extern "js" fn save_saved(raw : String) -> Bool = "(raw) => { try { localStorage.setItem('petgrowth-v1', raw); return true; } catch (_) { return false; } }"

///|
extern "js" fn local_today() -> String = "() => { const d = new Date(); const p = n => String(n).padStart(2, '0'); return `${d.getFullYear()}-${p(d.getMonth()+1)}-${p(d.getDate())}`; }"

///|
extern "js" fn choose_photo(callback : (String) -> Unit) -> Unit = "(callback) => window.petgrowthPickPhoto(callback)"

///|
extern "js" fn choose_backup(callback : (String) -> Unit) -> Unit = "(callback) => window.petgrowthPickBackup(callback)"

///|
extern "js" fn download_backup(raw : String) -> Unit = "(raw) => window.petgrowthDownloadBackup(raw)"

///|
extern "js" fn demo_requested() -> Bool = "() => new URLSearchParams(location.search).get('demo') === '1'"

///|
extern "js" fn set_demo_url(enabled : Bool) -> Unit = "(enabled) => { const url = new URL(location.href); if (enabled) url.searchParams.set('demo', '1'); else url.searchParams.delete('demo'); history.replaceState(null, '', url); }"

///|
fn initial_model() -> Model {
  let journal = @petgrowth.decode_journal(load_saved())
  {
    journal,
    page: "home",
    date: local_today(),
    diary_text: "",
    weight_text: "",
    photo: "",
    name: journal.pet.name,
    birthday: journal.pet.birthday,
    arrival_day: journal.pet.arrival_day,
    notice: "",
    demo: demo_requested(),
    card_index: if demo_requested() {
      2
    } else {
      0
    },
    growth_view: "timeline",
    modal: "",
    detail_id: 0,
    menu_open: false,
  }
}

///|
fn commit(
  model : Model,
  journal : @petgrowth.Journal,
  success : String,
) -> Model {
  let saved = save_saved(@petgrowth.encode_journal(journal))
  {
    ..model,
    journal,
    notice: if saved {
      success
    } else {
      "手机存储空间不足，请先导出备份。"
    },
  }
}

///|
fn update(
  emit : @rcmd.Emit[Msg],
  msg : Msg,
  model : Model,
) -> (@rcmd.Cmd, Model) {
  match msg {
    Page(value) => {
      let demo = if value == "settings" { false } else { model.demo }
      set_demo_url(demo)
      (
        @rcmd.none,
        { ..model, page: value, demo, notice: "", menu_open: false, },
      )
    }
    SelectCard(index) => (@rcmd.none, { ..model, card_index: index, })
    StepCard(step) => {
      let count = display_journal(model).diaries.length()
      let next = model.card_index + step
      (
        @rcmd.none,
        {
          ..model,
          card_index: if next < 0 {
            0
          } else if next >= count {
            count - 1
          } else {
            next
          },
        },
      )
    }
    GrowthView(value) => (@rcmd.none, { ..model, growth_view: value, })
    OpenComposer(kind) =>
      (@rcmd.none, { ..model, modal: kind, notice: "", menu_open: false, })
    CloseModal => (@rcmd.none, { ..model, modal: "", notice: "", })
    OpenDiary(id) =>
      (@rcmd.none, { ..model, modal: "diary-detail", detail_id: id, })
    OpenWeight(id) =>
      (@rcmd.none, { ..model, modal: "weight-detail", detail_id: id, })
    ToggleMenu => (@rcmd.none, { ..model, menu_open: !model.menu_open, })
    ToggleDemo => {
      set_demo_url(!model.demo)
      (
        @rcmd.none,
        {
          ..model,
          demo: !model.demo,
          card_index: if model.demo {
            0
          } else {
            2
          },
          menu_open: false,
          notice: "",
        },
      )
    }
    Date(value) => (@rcmd.none, { ..model, date: value, })
    DiaryText(value) => (@rcmd.none, { ..model, diary_text: value, })
    WeightText(value) => (@rcmd.none, { ..model, weight_text: value, })
    Name(value) => (@rcmd.none, { ..model, name: value, })
    Birthday(value) => (@rcmd.none, { ..model, birthday: value, })
    ArrivalDay(value) => (@rcmd.none, { ..model, arrival_day: value, })
    PickPhoto => {
      let cmd = @rcmd.custom_cmd(scheduler => {
        choose_photo(photo => {
          @rcmd.Scheduler::add(scheduler, emit(PhotoReady(photo)))
        })
      })
      (cmd, model)
    }
    PhotoReady(photo) =>
      if photo == "" {
        (
          @rcmd.none,
          { ..model, notice: "照片读取失败，请换一张试试。", },
        )
      } else {
        (
          @rcmd.none,
          { ..model, photo, notice: "照片已加入本次记录。", },
        )
      }
    PickAvatar => {
      let cmd = @rcmd.custom_cmd(scheduler => {
        choose_photo(photo => {
          @rcmd.Scheduler::add(scheduler, emit(AvatarReady(photo)))
        })
      })
      (cmd, model)
    }
    AvatarReady(photo) =>
      if photo == "" {
        (
          @rcmd.none,
          { ..model, notice: "头像读取失败，请换一张试试。", },
        )
      } else {
        (
          @rcmd.none,
          commit(
            model,
            @petgrowth.set_avatar(model.journal, photo),
            "宠物头像已保存。",
          ),
        )
      }
    SavePet =>
      if model.name.trim().length() == 0 {
        (@rcmd.none, { ..model, notice: "先给小家伙起个名字吧。", })
      } else {
        let journal = @petgrowth.set_pet(
          model.journal,
          model.name,
          model.birthday,
          model.arrival_day,
        )
        (@rcmd.none, commit(model, journal, "宠物档案已保存。"))
      }
    SaveDiary =>
      match
        @petgrowth.add_diary(
          model.journal,
          model.date,
          model.diary_text,
          model.photo,
        ) {
        Some(journal) => {
          set_demo_url(false)
          (
            @rcmd.none,
            {
              ..commit(model, journal, "今天的回忆收好了。"),
              diary_text: "",
              photo: "",
              page: "home",
              modal: "",
              demo: false,
              card_index: 0,
            },
          )
        }
        None =>
          (
            @rcmd.none,
            {
              ..model,
              notice: "请选择有效日期，并写点文字或添加照片。",
            },
          )
      }
    SaveWeight => {
      let grams = @petgrowth.parse_weight_kg(model.weight_text).unwrap_or(0)
      match
        @petgrowth.add_weight(model.journal, model.date, grams, model.photo) {
        Some(journal) => {
          set_demo_url(false)
          (
            @rcmd.none,
            {
              ..commit(model, journal, "体重已经记下来啦。"),
              weight_text: "",
              photo: "",
              page: "growth",
              modal: "",
              demo: false,
            },
          )
        }
        None =>
          (
            @rcmd.none,
            {
              ..model,
              notice: "请输入有效日期和 0.001–200 kg 的体重，最多三位小数。",
            },
          )
      }
    }
    DeleteDiary(id) =>
      (
        @rcmd.none,
        {
          ..commit(
            model,
            @petgrowth.remove_diary(model.journal, id),
            "这条日记已删除。",
          ),
          modal: "",
          card_index: 0,
        },
      )
    DeleteWeight(id) =>
      (
        @rcmd.none,
        {
          ..commit(
            model,
            @petgrowth.remove_weight(model.journal, id),
            "这次体重记录已删除。",
          ),
          modal: "",
        },
      )
    ToggleReminder => {
      let enabled = !model.journal.reminders_enabled
      let journal = @petgrowth.set_reminders(model.journal, enabled)
      let copy = if enabled {
        "已开启宠物提醒文案预览。"
      } else {
        "已关闭提醒文案预览。"
      }
      (@rcmd.none, commit(model, journal, copy))
    }
    ExportBackup => {
      download_backup(@petgrowth.encode_journal(model.journal))
      (@rcmd.none, { ..model, notice: "备份文件已开始下载。", })
    }
    ImportBackup => {
      let cmd = @rcmd.custom_cmd(scheduler => {
        choose_backup(raw => {
          @rcmd.Scheduler::add(scheduler, emit(BackupReady(raw)))
        })
      })
      (cmd, model)
    }
    BackupReady(raw) =>
      match @petgrowth.try_decode_journal(raw) {
        Some(journal) =>
          (
            @rcmd.none,
            {
              ..commit(model, journal, "备份已恢复。"),
              name: journal.pet.name,
              birthday: journal.pet.birthday,
              arrival_day: journal.pet.arrival_day,
            },
          )
        None =>
          (
            @rcmd.none,
            {
              ..model,
              notice: "这个文件不是有效的宠物日记备份。",
            },
          )
      }
  }
}

///|
fn main {
  @rabbita.new(() => {
    let (state, emit) = @rabbita.create_state(initial_model(), update=(
      model,
      msg,
      dispatcher,
    ) => {
      let (cmd, next) = update(dispatcher, msg, model)
      (next, cmd)
    })
    state.view(model => view(emit, model))
  }).mount("app")
}
