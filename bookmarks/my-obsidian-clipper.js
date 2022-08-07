javascript: (async function() {
  /* Optional vault name */
  const vault = "Personal";

  const daily_notes = "daily_notes/";

  /* Optional tags  */
  const tags = "#clippings";

  function convertDate(date) {
    var yyyy = date.getFullYear().toString();
    var mm = (date.getMonth() + 1).toString();
    var dd = date.getDate().toString();
    var mmChars = mm.split('');
    var ddChars = dd.split('');
    return yyyy + '-' + (mmChars[1] ? mm : "0" + mmChars[0]) + '-' + (ddChars[1] ? dd : "0" + ddChars[0]);
  }


  function getSelectionHtml() {
    var html = "";
    if (typeof window.getSelection != "undefined") {
      var sel = window.getSelection();
      if (sel.rangeCount) {
        var container = document.createElement("div");
        for (var i = 0, len = sel.rangeCount; i < len; ++i) {
          container.appendChild(sel.getRangeAt(i).cloneContents());
        }
        html = container.innerHTML;
      }
    } else if (typeof document.selection != "undefined") {
      if (document.selection.type == "Text") {
        html = document.selection.createRange().htmlText;
      }
    }
    return html;
  }

  const selection = getSelectionHtml();

  if (selection) {
    var markdownify = selection;
  } else {
    var markdownify = "";
  }

  if (vault) {
    var vaultName = '&vault=' + encodeURIComponent(`${vault}`);
  } else {
    var vaultName = '';
  }

  const today = convertDate(new Date());

  const sendToObsidian = function(content) {
    const new_location = `obsidian://new?file=${encodeURIComponent(daily_notes + today)}&content=${encodeURIComponent(content)}&append=true${vaultName}`;
    document.location.href = new_location
  }

  try {
    const {
      default: Turndown
    } = await import('https://unpkg.com/turndown@7.1.1?module')

    const markdownBody = new Turndown({
      headingStyle: 'atx',
      hr: '---',
      bulletListMarker: '-',
      codeBlockStyle: 'fenced',
      emDelimiter: '*',
    }).turndown(markdownify);
    const content = `- [${document.title}](${document.URL}) ${tags}\n --- \n ${markdownBody}\n`;
    const new_location = `obsidian://new?file=${encodeURIComponent(daily_notes + today)}&content=${encodeURIComponent(content)}&append=true${vaultName}`;
    document.location.href = new_location
  }
  catch (e) {
    console.log(e);
    const content = `- [${document.title}](${document.URL}) ${tags}\n`;
    const new_location = `obsidian://new?file=${encodeURIComponent(daily_notes + today)}&content=${encodeURIComponent(content)}&append=true${vaultName}`;
    document.location.href = new_location
  }

})();

