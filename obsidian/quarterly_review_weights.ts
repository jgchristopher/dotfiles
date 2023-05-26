const whenDate = "2023-05-23";
const quarterStart = moment(whenDate).startOf("quarter");
const quarterEnd = moment(whenDate).endOf("quarter");

function getFrontmatterWeight(file) {
  let weight = null;
  if (file.frontmatter) {
    if (file.frontmatter.weight) {
      weight = { x: moment(file.name).toDate(), y: file.frontmatter.weight };
    }
  }
  return weight;
}

const weightData = dv
  .pages('"daily_notes"')
  .where(
    (b) =>
      b.file.ctime >= quarterStart &&
      b.file.cday <= quarterEnd &&
      getFrontmatterWeight(b.file) != null
  )
  .sort((b) => b.file.cday, "ascending")
  .map((d) => getFrontmatterWeight(d.file));

const data = {
  datasets: [
    {
      label: "Daily Weighins",
      data: weightData.values,
      borderColor: "rgb(75, 192, 192)",
      tension: 0.1,
    },
  ],
};

const config = {
  type: "line",
  data: data,
  options: {
    scales: {
      y: {
        suggestedMin: 200,
        suggestedMax: 280,
      },
      x: {
        type: "time",
        time: {
          unit: "day",
        },
        min: quarterStart.toDate(),
        max: quarterEnd.toDate(),
      },
    },
  },
};

window.renderChart(config, this.container);
