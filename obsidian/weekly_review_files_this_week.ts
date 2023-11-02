const whenDate = "<% tp.date.now('YYYY-MM-DD')%>";
const weekStart = moment(whenDate).day(1);
const weekEnd = moment(whenDate).day(7);

function getFrontmatterTags(file) {
  let tags = "&#8211;"; // Return a - if empty
  if (file.frontmatter) {
    if (file.frontmatter.tags) {
      tags = file.frontmatter.tags;
    }
  }
  return tags;
}

dv.header(2, "All Files for the Week");
dv.table(
  ["File", "Path", "Tags", "Created"],
  dv
    .pages('""')
    .where((b) => b.file.ctime >= weekStart && b.file.cday <= weekEnd)
    .map((d) => [
      d.file.link,
      d.file.folder,
      getFrontmatterTags(d.file),
      d.file.cday,
    ]),
); //end table
