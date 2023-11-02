// Should be wrapped with ```dataviewjs ```

const whenDate = "<% tp.date.now('YYYY-MM-DD')%>";
const weekStart = moment(whenDate).day(1);
const weekEnd = moment(whenDate).day(7);
dv.header(2, "All Unreviewed Clippings");
dv.taskList(
  dv
    .pages('"daily_notes"')
    .where((b) => b.file.ctime >= weekStart && b.file.cday <= weekEnd)
    .file.tasks.where(
      (t) =>
        (t.text.includes("#obsidian-clipper") ||
          t.text.includes("#bookmark-clipper")) &&
        !t.completed,
    ),
);
