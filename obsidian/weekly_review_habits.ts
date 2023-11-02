const whenDate = "<% tp.date.now('YYYY-MM-DD')%>";
const weekStart = moment(whenDate).day(1);
const weekEnd = moment(whenDate).day(7);

function getFrontmatterData(file) {
  let info = null;
  if (file.frontmatter) {
    if (file.frontmatter.weight) {
      info = {
        x: moment(file.name).toDate(),
        y: file.frontmatter.weight,
        y2: file.frontmatter.happiness,
      };
    }
  }
  return info;
}

const dataInfo = dv
  .pages('"daily_notes"')
  .where(
    (b) =>
      b.file.ctime >= weekStart &&
      b.file.cday <= weekEnd &&
      getFrontmatterData(b.file) != null,
  )
  .sort((b) => b.file.cday, "ascending")
  .map((d) => getFrontmatterData(d.file));

const weightData = dataInfo.values.map((w) => {
  return { x: w.x, y: w.y };
});

const happinessData = dataInfo.values.map((h) => {
  return { x: h.x, y: h.y2 };
});

const data = {
  datasets: [
    {
      label: "Daily Weighins",
      data: weightData,
      borderColor: "rgb(75, 192, 192)",
      backgroundColor: "rgb(75, 192, 192)",
      tension: 0.1,
    },
    {
      yAxisID: "y2",
      label: "Daily Happiness",
      data: happinessData,
      borderColor: "rgb(255, 99, 132)",
      backgroundColor: "rgb(255, 99, 132)",
      stepped: true,
    },
  ],
};

const config = {
  type: "line",
  data: data,
  options: {
    scales: {
      y: {
        type: "linear",
        position: "left",
        stack: "mydata",
        stackWeight: 2,
        suggestedMin: 200,
        suggestedMax: 280,
        border: {
          display: true,
          color: "rgb(75, 192, 192)",
          width: 2,
          z: 5,
        },
      },
      y2: {
        position: "left",
        stack: "mydata",
        type: "category",
        labels: ["😀", "🫤", "🙃", "😡"],
        offset: true,
        stackWeight: 1,
        border: {
          color: "rgb(255, 99, 132)",
        },
      },
      x: {
        type: "time",
        time: {
          unit: "day",
        },
        min: weekStart.toDate(),
        max: weekEnd.toDate(),
      },
    },
  },
};

window.renderChart(config, this.container);
