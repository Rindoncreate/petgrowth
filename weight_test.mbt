///|
test "kilogram input preserves gram precision without floating point rounding" {
  for
    (raw, grams) in [
      ("4", 4000),
      ("4.1", 4100),
      ("4.01", 4010),
      ("4.001", 4001),
      ("0.001", 1),
      ("200.000", 200000),
      (" 4.125 ", 4125),
    ] {
    assert_eq(@petgrowth.parse_weight_kg(raw), Some(grams))
  }
}

///|
test "invalid kilogram inputs cannot enter the chart" {
  for
    raw in [
      "", " ", "0", "0.000", "-1", "+4", "NaN", "Infinity", "1e2", "0x10", "200.001",
      "201", "99999999999999999999999", "4.1234", "4..2", "4,2", ".5", "4.", "四",
      "４.２",
    ] {
    assert_eq(@petgrowth.parse_weight_kg(raw), None)
  }
}
