### Transparency

So you want a transparent terminal huh? Can't say I blame you. This theme allows you to customize the background transparency by setting a value in your `~/.hyper.js` config. Just create a property called `transparentBgAlpha` in the `config` object and give it a value. This value will be passed into the background color in the theme as the `a` portion of the `rgba` (if you don't add this property, it defaults to 1, which is no transparency). So for example, if you want your terminal to have 70% alpha, this is what you'd do:

```js
// ~/.hyper.js

module.exports = {
  config = {
    // your normal settings and stuff
    ...

    // add this one!
    transparentBgAlpha: 0.7,

    // maybe more stuff here?
  },
  plugins: [
    ...
  ],
  localPlugins: [
    'hyper-electron-highlighter-jc'
  ]
}
```

### License

MIT
