import moment from "moment";

const nextSunday = moment("<% tp.date.now('YYYY-MM-DD')%>")
  .day(7)
  .set({ hour: 23, minute: 59, second: 59, millisecond: 0 });
const lastMonday = moment("<% tp.date.now('YYYY-MM-DD')%>")
  .day(1)
  .set({ hour: 0, minute: 0, second: 0, millisecond: 0 });

function getFrontmatterTags(file) {
  let tags = "&#8211;"; // Return a - if empty
  if (file.frontmatter) {
    if (file.frontmatter.tags) {
      tags = "";
      file.frontmatter.tags.split(",").forEach((t) => {
        tags += ` #${t}`;
      });
    }
  }
  return tags;
}

dv.header(2, "All Files for the Week");
dv.table(
  ["File", "Path", "Tags", "Created"],
  dv
    .pages('""')
    .where((b) => b.file.ctime >= lastMonday && b.file.cday <= nextSunday)
    .map((d) => [
      d.file.link,
      d.file.folder,
      getFrontmatterTags(d.file),
      d.file.cday,
    ])
); //end table
