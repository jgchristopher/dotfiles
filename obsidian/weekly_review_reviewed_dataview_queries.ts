import moment from "moment";

const nextSunday = moment("<% tp.date.now('YYYY-MM-DD')%>")
  .day(7)
  .set({ hour: 23, minute: 59, second: 59, millisecond: 0 });
const lastMonday = moment("<% tp.date.now('YYYY-MM-DD')%>")
  .day(1)
  .set({ hour: 0, minute: 0, second: 0, millisecond: 0 });
dv.header(2, "All Unreviewed Clippings");
dv.taskList(
  dv
    .pages('"daily_notes"')
    .where((b) => b.file.ctime >= lastMonday && b.file.cday <= nextSunday)
    .file.tasks.where(
      (t) =>
        (t.text.includes("#obsidian-clipper") ||
          t.text.includes("#bookmark-clipper")) &&
        t.completed
    )
);
