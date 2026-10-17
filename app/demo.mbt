///|
fn demo_journal() -> @petgrowth.Journal {
  {
    pet: {
      name: "布丁",
      birthday: "2026-05-18",
      arrival_day: "2026-06-29",
      avatar: "demo:5",
    },
    diaries: [
      {
        id: 1,
        date: "2026-06-29",
        text: "你好呀，小布丁。\n从今天开始，这里就是你的家啦。",
        photo: "demo:0",
      },
      {
        id: 2,
        date: "2026-07-14",
        text: "第一次带你去草地，\n每一片叶子都要认真闻一闻。",
        photo: "demo:1",
      },
      {
        id: 3,
        date: "2026-07-24",
        text: "你又长大了一点。\n还是喜欢把脑袋，\n轻轻靠在我的膝盖上。",
        photo: "demo:2",
      },
      {
        id: 4,
        date: "2026-08-02",
        text: "今天学会握手了！\n一只小爪子换一颗零食，\n这笔生意你很满意。",
        photo: "demo:3",
      },
      {
        id: 5,
        date: "2026-08-11",
        text: "长得好快，一天一个样。\n午后的阳光刚刚好，\n你在身边睡了一个长长的觉。",
        photo: "demo:4",
      },
      {
        id: 6,
        date: "2026-08-19",
        text: "回家的时候，\n总有一条摇个不停的小尾巴。\n平常的一天，也变得很可爱。",
        photo: "demo:5",
      },
    ],
    weights: [
      { id: 11, date: "2026-06-29", grams: 2600, photo: "demo:0", },
      { id: 12, date: "2026-07-14", grams: 3600, photo: "demo:1", },
      { id: 13, date: "2026-07-24", grams: 4100, photo: "demo:2", },
      { id: 14, date: "2026-08-02", grams: 4800, photo: "demo:3", },
      { id: 15, date: "2026-08-11", grams: 5800, photo: "demo:4", },
      { id: 16, date: "2026-08-19", grams: 6300, photo: "demo:5", },
    ],
    next_id: 17,
    reminders_enabled: true,
  }
}

///|
fn display_journal(model : Model) -> @petgrowth.Journal {
  if model.demo {
    demo_journal()
  } else {
    model.journal
  }
}
