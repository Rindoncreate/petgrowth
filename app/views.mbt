///|
using @html {
  type Html,
  div,
  h1,
  h2,
  p,
  span,
  button,
  input,
  textarea,
  img,
  label,
  main_,
  nav,
}

///|
fn icon(name : String) -> Html {
  let d = match name {
    "journal" => "M6 3h12v18H6z M9 7h6 M9 11h6 M9 15h4"
    "album" => "M3 5h18v14H3z M3 16l5-5 4 4 3-3 6 6 M16 8h.01"
    "growth" => "M12 3v18 M4 8h8 M12 14h8 M4 6v4 M20 12v4 M8 21h8"
    "bell" => "M8 19h8 M10 22h4 M5 17l2-3V9a5 5 0 0 1 10 0v5l2 3z"
    "camera" => "M8 6l2-3h4l2 3h5v14H3V6z M16 13a4 4 0 1 1-8 0a4 4 0 1 1 8 0"
    "tree" => "M7 5h10 M7 10h10 M7 15h10 M7 20h10"
    "chart" => "M4 3v17h17 M8 15l4-5 4 2 5-6"
    "close" => "M6 6l12 12 M18 6L6 18"
    "left" => "M14 6l-6 6 6 6"
    "right" => "M10 6l6 6-6 6"
    "more" => "M5 12h.01 M12 12h.01 M19 12h.01"
    "plus" => "M12 5v14 M5 12h14"
    "download" => "M12 3v12 M7 10l5 5 5-5 M4 16v5h16v-5"
    _ => "M12 3a9 9 0 1 0 0 18a9 9 0 1 0 0-18"
  }
  @svg.svg(class="icon", view_box="0 0 24 24", [
    @svg.path(d~, fill="none", stroke="currentColor", stroke_width=2),
  ])
}

///|
fn icon_button(
  emit : @rcmd.Emit[Msg],
  msg : Msg,
  glyph : String,
  title : String,
  active~ : Bool = false,
) -> Html {
  button(
    class=if active { "icon-button is-active" } else { "icon-button" },
    title~,
    attrs=@html.Attrs::build().aria_label(title),
    on_click=emit(msg),
    icon(glyph),
  )
}

///|
fn photo_view(photo : String, class_name : String) -> Html {
  let index = match photo {
    "demo:0" => 0
    "demo:1" => 1
    "demo:2" => 2
    "demo:3" => 3
    "demo:4" => 4
    "demo:5" => 5
    _ => -1
  }
  if index >= 0 {
    div(
      class="pet-sprite sprite-\{index} \{class_name}",
      attrs=@html.Attrs::build().role("img").aria_label("布丁的成长照片"),
      "",
    )
  } else if photo == "" {
    div(class="photo-empty \{class_name}", icon("camera"))
  } else {
    img(class=class_name, src=photo, alt="宠物成长照片")
  }
}

///|
fn short_date(date : String) -> String {
  if date.length() == 10 {
    "\{date[5:7]}/\{date[8:10]}"
  } else {
    date
  }
}

///|
fn age_text(birthday : String, date : String) -> String {
  match (@petgrowth.day_number(birthday), @petgrowth.day_number(date)) {
    (Some(born), Some(day)) if day >= born =>
      if day - born < 60 {
        "\{(day - born) / 7}周"
      } else {
        "\{(day - born) / 30}个月"
      }
    _ => ""
  }
}

///|
fn top_bar(emit : @rcmd.Emit[Msg], model : Model) -> Html {
  let title = match model.page {
    "growth" => "体重"
    "album" => "相册"
    "reminders" => "提醒"
    "settings" => "我的档案"
    _ => "日记"
  }
  div(class="topbar", [
    h1(title),
    div(class="topbar-actions", [
      if model.demo {
        span(class="demo-badge", "示例手帐")
      } else {
        span("")
      },
      if model.page == "growth" {
        div(class="view-switch", [
          icon_button(
            emit,
            GrowthView("timeline"),
            "tree",
            "成长时光轴",
            active=model.growth_view == "timeline",
          ),
          icon_button(
            emit,
            GrowthView("chart"),
            "chart",
            "体重折线图",
            active=model.growth_view == "chart",
          ),
        ])
      } else {
        span("")
      },
      icon_button(emit, ToggleMenu, "more", "更多"),
    ]),
    if model.menu_open {
      div(class="popover", [
        button(on_click=emit(Page("settings")), "宠物档案"),
        button(
          on_click=emit(ToggleDemo),
          if model.demo {
            "回到我的手帐"
          } else {
            "看看示例手帐"
          },
        ),
        button(on_click=emit(ExportBackup), "导出我的备份"),
      ])
    } else {
      div(hidden=true, "")
    },
  ])
}

///|
fn bottom_bar(emit : @rcmd.Emit[Msg], model : Model) -> Html {
  nav(class="bottom-nav", [
    icon_button(
      emit,
      Page("home"),
      "journal",
      "日记",
      active=model.page == "home",
    ),
    icon_button(
      emit,
      Page("album"),
      "album",
      "相册",
      active=model.page == "album",
    ),
    button(
      class="shutter",
      title="添加记录",
      attrs=@html.Attrs::build().aria_label("添加记录"),
      on_click=emit(
        OpenComposer(if model.page == "growth" { "weight" } else { "diary" }),
      ),
      span(""),
    ),
    icon_button(
      emit,
      Page("growth"),
      "growth",
      "成长",
      active=model.page == "growth",
    ),
    icon_button(
      emit,
      Page("reminders"),
      "bell",
      "提醒",
      active=model.page == "reminders",
    ),
  ])
}

///|
fn empty_page(
  emit : @rcmd.Emit[Msg],
  title : String,
  subtitle : String,
  kind : String,
) -> Html {
  div(class="empty-page", [
    div(
      class="empty-drawing",
      icon(if kind == "diary" { "journal" } else { "growth" }),
    ),
    h2(title),
    p(subtitle),
    button(
      class="olive-button",
      on_click=emit(OpenComposer(kind)),
      "记下第一笔",
    ),
    button(
      class="text-button",
      on_click=emit(ToggleDemo),
      "先看看示例手帐",
    ),
  ])
}

///|
fn home_page(emit : @rcmd.Emit[Msg], model : Model) -> Html {
  let diaries = @petgrowth.diaries_newest_first(display_journal(model))
  if diaries.length() == 0 {
    return main_(class="page diary-page", [
      empty_page(
        emit, "一本属于你们的日记", "把和它的小小日常，慢慢收集起来。",
        "diary",
      ),
    ])
  }
  let selected = if model.card_index >= diaries.length() {
    0
  } else {
    model.card_index
  }
  let cards = diaries.mapi((i, entry) => {
    let offset = i - selected
    let distance = if offset < 0 { -offset } else { offset }
    button(
      class=if offset == 0 {
        "diary-paper current"
      } else if offset > 0 {
        "diary-paper after"
      } else {
        "diary-paper"
      },
      style=[
        "--offset:\{offset}",
        "--distance:\{distance}",
        "z-index:\{50 - distance}",
      ],
      hidden=distance > 2,
      attrs=@html.Attrs::build()
        .aria_label("日记 \{entry.date}")
        .aria_current(if offset == 0 { "true" } else { "false" }),
      on_click=emit(
        if offset == 0 {
          OpenDiary(entry.id)
        } else {
          SelectCard(i)
        },
      ),
      [
        div(class="paper-copy", [
          span(class="paper-date", entry.date),
          p(entry.text),
        ]),
        if entry.photo == "" {
          div("")
        } else {
          div(class="taped-photo", [photo_view(entry.photo, "diary-photo")])
        },
        span(class="paper-index", "\{i + 1} / \{diaries.length()}"),
      ],
    )
  })
  main_(class="page diary-page", [
    div(class="diary-deck", cards),
    div(class="deck-controls", [
      button(
        id="card-prev",
        class="quiet-button",
        disabled=selected == 0,
        title="上一篇日记",
        attrs=@html.Attrs::build().aria_label("上一篇日记"),
        on_click=emit(StepCard(-1)),
        icon("left"),
      ),
      span("轻滑翻阅 · 点击展开"),
      button(
        id="card-next",
        class="quiet-button",
        disabled=selected == diaries.length() - 1,
        title="下一篇日记",
        attrs=@html.Attrs::build().aria_label("下一篇日记"),
        on_click=emit(StepCard(1)),
        icon("right"),
      ),
    ]),
  ])
}

///|
fn tree_view(emit : @rcmd.Emit[Msg], journal : @petgrowth.Journal) -> Html {
  let weights = @petgrowth.weights_oldest_first(journal)
  let newest = weights.mapi((i, _) => weights[weights.length() - i - 1])
  let rows = newest.mapi((i, entry) => {
    button(
      class=if i % 2 == 0 { "tree-entry right" } else { "tree-entry left" },
      attrs=@html.Attrs::build().aria_label("查看 \{entry.date} 体重记录"),
      on_click=emit(OpenWeight(entry.id)),
      [
        photo_view(entry.photo, "tree-photo"),
        div(class="tree-caption", [
          span(
            class="record-date",
            "\{entry.date} · \{age_text(journal.pet.birthday, entry.date)}",
          ),
          span(class="record-weight", @petgrowth.format_grams_kg(entry.grams)),
          span(
            class="record-note",
            if i == 0 {
              "又悄悄长大了一点"
            } else {
              "慢慢长大，好好记录"
            },
          ),
        ]),
      ],
    )
  })
  div(class="growth-scroll", [
    div(class="growth-tree", [
      div(class="tree-stem", ""),
      div(class="tree-entries", rows),
      span(class="tree-origin", "故事从这里开始"),
    ]),
  ])
}

///|
fn chart_view(emit : @rcmd.Emit[Msg], journal : @petgrowth.Journal) -> Html {
  let weights = @petgrowth.weights_oldest_first(journal)
  let mut max_grams = 60000
  for entry in weights {
    if entry.grams > max_grams {
      max_grams = (entry.grams / 10000 + 1) * 10000
    }
  }
  let width = if weights.length() > 6 {
    weights.length() * 60 + 40
  } else {
    350
  }
  let step = if weights.length() > 1 {
    (width - 80) / (weights.length() - 1)
  } else {
    1
  }
  let points = weights.mapi((i, entry) => {
    (40 + i * step, 284 - entry.grams * 252 / max_grams)
  })
  let elements : Array[@svg.Svg] = []
  for i = 0; i <= 6; i = i + 1 {
    let y = 284 - i * 42
    elements.push(
      @svg.line(x1=0, y1=y, x2=5, y2=y, stroke="#c0c0b3", stroke_width=1),
    )
  }
  elements.push(
    @svg.polyline(points~, fill="none", stroke="#66694e", stroke_width=2),
  )
  for point in points {
    elements.push(
      @svg.circle(
        cx=point.0,
        cy=point.1,
        r=4,
        fill="#fbfaf6",
        stroke="#66694e",
        stroke_width=2,
      ),
    )
  }
  let axis = Array::makei(7, i => {
    span(style=["top:\{(6 - i) * 42 + 25}px"], "\{i * max_grams / 6000}")
  })
  let photos = weights.mapi((i, entry) => {
    let size = 42 + entry.grams * 18 / weights[weights.length() - 1].grams
    button(
      class="chart-pet",
      style=["left:\{40 + i * step}px"],
      on_click=emit(OpenWeight(entry.id)),
      [
        div(class="chart-photo-slot", [
          div(style=["width:\{size}px", "height:\{size * 3 / 2}px"], [
            photo_view(entry.photo, "chart-photo"),
          ]),
        ]),
        span(class="chart-weight", @petgrowth.format_grams_kg(entry.grams)),
        span(short_date(entry.date)),
        span(age_text(journal.pet.birthday, entry.date)),
      ],
    )
  })
  div(class="chart-page", [
    div(class="chart-axis", [span(class="axis-unit", "kg"), div(axis)]),
    div(class="chart-scroll", [
      div(class="chart-content", style=["width:\{width}px"], [
        @svg.svg(
          class="weight-graph",
          width~,
          height=310,
          view_box="0 0 \{width} 310",
          elements,
        ),
        div(class="chart-pets", photos),
      ]),
    ]),
    p(class="chart-hint", "体重与模样，一起慢慢长大"),
  ])
}

///|
fn growth_page(emit : @rcmd.Emit[Msg], model : Model) -> Html {
  let journal = display_journal(model)
  main_(class="page growth-page", [
    if journal.weights.length() == 0 {
      empty_page(
        emit, "看着它一点点长大", "记一次体重，留住这个时候的模样。",
        "weight",
      )
    } else if model.growth_view == "timeline" {
      tree_view(emit, journal)
    } else {
      chart_view(emit, journal)
    },
    if journal.weights.length() > 0 {
      button(
        class="floating-add olive-button",
        on_click=emit(OpenComposer("weight")),
        [icon("camera"), span("记体重")],
      )
    } else {
      div("")
    },
  ])
}

///|
fn album_page(emit : @rcmd.Emit[Msg], model : Model) -> Html {
  let entries = @petgrowth.diaries_newest_first(display_journal(model)).filter(entry => {
    entry.photo != ""
  })
  main_(class="page album-page", [
    if entries.length() == 0 {
      empty_page(
        emit, "收藏每一张可爱", "拍一张照片，留住今天的它。",
        "diary",
      )
    } else {
      div(
        class="album-scatter",
        entries.mapi((i, entry) => {
          button(
            class="album-item",
            style=["--tilt:\{(i % 3 - 1) * 8}deg"],
            on_click=emit(OpenDiary(entry.id)),
            [
              photo_view(entry.photo, "album-photo"),
              span(short_date(entry.date)),
            ],
          )
        }),
      )
    },
  ])
}

///|
fn reminders_page(emit : @rcmd.Emit[Msg], model : Model) -> Html {
  let journal = display_journal(model)
  let copy = match @petgrowth.reminder_text(journal, local_today(), 0) {
    Some(value) => value
    None => "今天的你，也有想要留住的小事吗？"
  }
  main_(class="page simple-page", [
    div(class="letter", [
      span(class="letter-to", "给最喜欢的你"),
      p(copy),
      span(
        class="letter-sign",
        "—— \{if journal.pet.name == "" { "你的小伙伴" } else { journal.pet.name }}",
      ),
    ]),
    button(
      class="olive-button",
      on_click=emit(OpenComposer("diary")),
      "给它写一篇日记",
    ),
    p(
      class="quiet-copy",
      "这里是宠物口吻的问候预览。\n系统通知尚未接入。",
    ),
  ])
}

///|
fn settings_page(emit : @rcmd.Emit[Msg], model : Model) -> Html {
  main_(class="page settings-page", [
    div(class="profile-photo", [
      photo_view(model.journal.pet.avatar, "avatar"),
      button(class="text-button", on_click=emit(PickAvatar), "换一张头像"),
    ]),
    div(class="form-fields", [
      label(for_="pet-name", "名字"),
      input(id="pet-name", value=model.name, placeholder="宠物叫什么？", on_input=value => {
        emit(Name(value))
      }),
      label(for_="birthday", "生日"),
      input(id="birthday", input_type=Date, value=model.birthday, on_input=value => {
        emit(Birthday(value))
      }),
      label(for_="arrival", "到家日"),
      input(id="arrival", input_type=Date, value=model.arrival_day, on_input=value => {
        emit(ArrivalDay(value))
      }),
      button(class="olive-button wide", on_click=emit(SavePet), "保存档案"),
    ]),
    div(class="settings-section", [
      h2("好好保存每一天"),
      p(
        "记录与照片保存在当前浏览器。可以导出备份，换设备时再导入。",
      ),
      div(class="button-row", [
        button(class="soft-button", on_click=emit(ExportBackup), "导出备份"),
        button(class="soft-button", on_click=emit(ImportBackup), "导入备份"),
      ]),
      button(
        class="text-button",
        on_click=emit(ToggleReminder),
        if model.journal.reminders_enabled {
          "关闭宠物问候"
        } else {
          "开启宠物问候"
        },
      ),
    ]),
    p(class="app-signature", "爪记 · 把日子过成一本手帐"),
  ])
}

///|
fn composer(emit : @rcmd.Emit[Msg], model : Model) -> Html {
  let weight = model.modal == "weight"
  div(
    class="sheet",
    attrs=@html.Attrs::build()
      .role("dialog")
      .aria_modal("true")
      .aria_label(if weight { "记体重" } else { "写日记" }),
    [
      div(class="sheet-handle", ""),
      div(class="sheet-header", [
        h2(if weight { "记一次体重" } else { "记下今天" }),
        icon_button(emit, CloseModal, "close", "关闭"),
      ]),
      div(class="composer-tabs", [
        button(
          class=if weight { "" } else { "selected" },
          on_click=emit(OpenComposer("diary")),
          "日记",
        ),
        button(
          class=if weight { "selected" } else { "" },
          on_click=emit(OpenComposer("weight")),
          "体重",
        ),
      ]),
      div(class="form-fields", [
        label(for_="record-date", "日期"),
        input(id="record-date", input_type=Date, value=model.date, on_input=value => {
          emit(Date(value))
        }),
        if weight {
          div(class="weight-input-row", [
            input(
              id="record-weight",
              input_type=Text,
              inputmode="decimal",
              value=model.weight_text,
              placeholder="0.00",
              attrs=@html.Attrs::build().aria_label("体重 kg"),
              on_input=value => emit(WeightText(value)),
            ),
            span("kg"),
          ])
        } else {
          textarea(
            value=model.diary_text,
            rows=5,
            placeholder="今天和它，发生了什么小事？",
            attrs=@html.Attrs::build().aria_label("日记内容"),
            on_input=value => emit(DiaryText(value)),
            "",
          )
        },
        button(class="photo-picker", on_click=emit(PickPhoto), [
          if model.photo == "" {
            icon("camera")
          } else {
            photo_view(model.photo, "upload-thumb")
          },
          span(
            if model.photo == "" {
              "加一张照片"
            } else {
              "换一张照片"
            },
          ),
        ]),
        if model.demo {
          p(
            class="quiet-copy",
            "保存后，这条记录会加入你的手帐。",
          )
        } else {
          div("")
        },
        button(
          class="olive-button wide",
          on_click=emit(if weight { SaveWeight } else { SaveDiary }),
          "保存这一天",
        ),
      ]),
    ],
  )
}

///|
fn detail_sheet(emit : @rcmd.Emit[Msg], model : Model) -> Html {
  let journal = display_journal(model)
  let body : Array[Html] = []
  if model.modal == "diary-detail" {
    for entry in journal.diaries {
      if entry.id == model.detail_id {
        body.push(span(class="detail-date", entry.date))
        body.push(p(class="detail-copy", entry.text))
        if entry.photo != "" {
          body.push(photo_view(entry.photo, "detail-photo"))
        }
        if !model.demo {
          body.push(
            button(
              class="text-button danger",
              on_click=emit(DeleteDiary(entry.id)),
              "删除这篇日记",
            ),
          )
        }
      }
    }
  } else {
    for entry in journal.weights {
      if entry.id == model.detail_id {
        body.push(span(class="detail-date", entry.date))
        body.push(
          h2(class="detail-weight", @petgrowth.format_grams_kg(entry.grams)),
        )
        body.push(photo_view(entry.photo, "detail-photo"))
        if !model.demo {
          body.push(
            button(
              class="text-button danger",
              on_click=emit(DeleteWeight(entry.id)),
              "删除这条记录",
            ),
          )
        }
      }
    }
  }
  div(
    class="sheet detail-sheet",
    attrs=@html.Attrs::build()
      .role("dialog")
      .aria_modal("true")
      .aria_label("记录详情"),
    [
      div(class="sheet-header", [
        span("好好收藏的这一天"),
        icon_button(emit, CloseModal, "close", "关闭"),
      ]),
      div(class="detail-body", body),
    ],
  )
}

///|
fn view(emit : @rcmd.Emit[Msg], model : Model) -> Html {
  div(class="app-shell", [
    top_bar(emit, model),
    match model.page {
      "growth" => growth_page(emit, model)
      "album" => album_page(emit, model)
      "reminders" => reminders_page(emit, model)
      "settings" => settings_page(emit, model)
      _ => home_page(emit, model)
    },
    bottom_bar(emit, model),
    if model.modal == "" {
      div("")
    } else {
      div(class="modal-layer", [
        button(
          class="modal-backdrop",
          attrs=@html.Attrs::build().aria_label("关闭弹窗"),
          on_click=emit(CloseModal),
          "",
        ),
        if model.modal == "diary" || model.modal == "weight" {
          composer(emit, model)
        } else {
          detail_sheet(emit, model)
        },
      ])
    },
    if model.notice == "" {
      div("")
    } else {
      div(
        class="toast",
        attrs=@html.Attrs::build().role("status"),
        model.notice,
      )
    },
  ])
}
