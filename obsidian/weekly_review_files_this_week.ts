let now = dv.date("2022-11-24");
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
    .where(function (b) {
      if (
        b.file.cday >= moment(now).subtract(7, "days") &&
        b.file.cday <= now
      ) {
        return b;
      }
    })
    .map((d) => [
      d.file.link,
      d.file.folder,
      getFrontmatterTags(d.file),
      d.file.cday,
    ])
); //end table
