'use strict'
const black = '#212836'
const white = '#97a7c8'
const red = '#e76572'
const green = '#6af699'
const yellow = '#fffa9e'
const blue = '#71b1fe'
const magenta = '#d59df6'
const cyan = '#4ff2f8'

const colors = {
  black,
  red,
  green,
  yellow,
  blue,
  magenta,
  cyan,
  white,
  lightBlack: black,
  lightRed: red,
  lightGreen: green,
  lightYellow: yellow,
  lightBlue: blue,
  lightMagenta: magenta,
  lightCyan: cyan,
  lightWhite: white
}

exports.decorateConfig = config => {
  const transparencyValue = config.transparentBgAlpha || 1
  const backgroundColor = `rgba(33,40,54,${transparencyValue})`
  const foregroundColor = white
  //const cursorColor = 'rgba(82,139,255,.7)'
  //const borderColor = '#4d596b'
  const cursorColor = '#9370DB'
  const borderColor = '#9370DB'
  const tabBgDark = 'rgba(0,0,0,.15)'
  const tabText = 'rgba(153,163,184)'
  const tabTextActive = '#d5d9e2'
  const dividerBg = borderColor

  return Object.assign({}, config, {
    foregroundColor,
    backgroundColor,
    borderColor,
    cursorColor,
    colors,
    termCSS: `
      ${config.termCSS || ''}
      .cursor-node {
        mix-blend-mode: difference;
      }
    `,
    css: `
      ${config.css || ''}
      .tabs_list {
        margin-left: 0;
      }
      .tab_tab.tab_first {
        padding-left: 82px;
      }
      .tab_textInner {
        color: ${tabText};
      }
      .tab_tab:not(.tab_active) {
        background-color: ${tabBgDark};
      }
      .tab_tab.tab_active .tab_textInner {
        color: ${tabTextActive};
      }
      .tab_tab.tab_active {
        font-weight: 600;
      }
      .tab_firstActive {
        border-left-width: 0px;
      }
      .tabs_borderShim {
        border-width: 0 !important;
      }
      .splitpane_divider {
        background-color: ${dividerBg};
      }
    `
  })
}
