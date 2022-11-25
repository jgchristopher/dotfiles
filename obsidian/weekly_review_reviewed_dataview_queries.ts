dv.header(2, "All Reviewed Clippings");
dv.taskList(
  dv
    .pages('"daily_notes"')
    .where((b) => {
      b.file.ctime >=
        moment("<% tp.date.now('YYYY-MM-DD')%>").subtract(6, "days") &&
        b.file.cday <= moment("<% tp.date.now('YYYY-MM-DD')%>");
    })
    .file.tasks.where(
      (t) => t.text.includes("#bookmark-clipper") && t.completed
    )
);
