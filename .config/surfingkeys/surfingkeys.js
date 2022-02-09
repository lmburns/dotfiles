const {
  aceVimMap,
  mapkey,
  imap,
  imapkey,
  getClickableElements,
  vmapkey,
  map,
  unmap,
  vunmap,
  cmap,
  addSearchAlias,
  removeSearchAlias,
  tabOpenLink,
  readText,
  Clipboard,
  Front,
  Hints,
  Visual,
  RUNTIME,
} = api;

settings.tabsMRUOrder = false;

// "border: solid 3px #552a48; color:#efe1eb; background: none; background-color: #552a48;"
api.Hints.style(
  "padding: 1px; color:#ddc7a1; background: none; background-color: #b16286"
);

api.Hints.style(
  "div{color:#ddc7a1; background: none; background-color: #7daea3;} div.begin{color:#ea6962;}",
  "text"
);

// Emoji
api.iunmap(":");
// Baidu search
api.unmap("ob");

// Left move tab
api.map("h", "E");
// Right move tab
api.map("l", "R");

// Backward history
api.map("H", "S");
// Forward history
api.map("L", "D");

// Up
api.map("K", "u");
// Down
api.map("J", "d");

// Close tab
api.map("D", "x");

api.mapkey("d", "#3Close current tab", function () {
  api.RUNTIME("closeTab");
});

api.mapkey("u", "#3Restore closed tab", function () {
  api.RUNTIME("openLast");
});

// Scroll Page Down/Up
// api.mapkey("<Ctrl-d>", "#9Forward half page", function () {
//   api.Normal.feedkeys("3j");
// });
// api.mapkey("<Ctrl-u>", "#9Back half page", function () {
//   api.Normal.feedkeys("3k");
// });

// Next/Prev Page
api.map("]", "]]");
api.map("[", "[[");

// api.mapkey(
//   "K",
//   "#1Click on the previous link on current page",
//   api.previousPage
// );
// api.mapkey("J", "#1Click on the next link on current page", api.nextPage);

// Move Tab Left/Right
api.map(">", ">>");
api.map("<", "<<");

// cmap("<Ctrl-n>", "<Tab>");
// cmap("<Ctrl-p>", "<Shift-Tab>");

api.mapkey("T", "Choose a tab with omnibar", function () {
  api.Front.openOmnibar({ type: "Tabs" });
});

api.mapkey("gt", "#8Open a URL", function () {
  api.Front.openOmnibar({ type: "URLs", extra: "getAllSites" });
});

// api.mapkey("t", "#3Choose a tab", function () {
//   api.Front.chooseTab();
// });

// api.mapkey("<Ctrl-n", "Print all mappings to console", function () {
//   const feature_groups = [
//     "Help", // 0
//     "Mouse Click", // 1
//     "Scroll Page / Element", // 2
//     "Tabs", // 3
//     "Page Navigation", // 4
//     "Sessions", // 5
//     "Search selected with", // 6
//     "Clipboard", // 7
//     "Omnibar", // 8
//     "Visual Mode", // 9
//     "vim-like marks", // 10
//     "Settings", // 11
//     "Chrome URLs", // 12
//     "Proxy", // 13
//     "Misc", // 14
//     "Insert Mode", // 15
//   ];
//
//   let keyMappings = [
//     api.Normal.mappings,
//     api.Visual.mappings,
//     api.Insert.mappings,
//   ]
//     .map(getAnnotations)
//     .reduce(function (a, b) {
//       return a.concat(b);
//     });
//
//   keyMappings = keyMappings.map((annotation) => {
//     let category_name = feature_groups[annotation.feature_group];
//     return {
//       category: category_name,
//       trigger:
//         KeyboardUtils.decodeKeystroke(annotation.word) + ` (${category_name})`,
//       description: annotation.annotation,
//     };
//   });
//
//   console.log(command_map);
//   let commands = Object.keys(command_map).map((commandName) => {
//     console.log("processing: " + commandName);
//     let cmd = command_map[commandName];
//     let category_name = feature_groups[cmd.feature_group];
//     return {
//       category: category_name,
//       trigger: `:${commandName} (${category_name})`,
//       description: cmd.annotation,
//     };
//   });
//
//   console.log(keyMappings.concat(commands));
//   console.log(JSON.stringify(keyMappings.concat(commands)));
// });

settings.theme = `
.sk_theme {
    background: #282828;
    color: #7daea3;
}
.sk_theme tbody {
    color: #8bba7f;
}
.sk_theme input {
    color: #ddc7a1;
}
.sk_theme .url {
    color: #a9b665;
}
.sk_theme .annotation {
    color: #b16286;
}
.sk_theme .omnibar_highlight {
    color: #333;
    background: #e78a4e;
}
.sk_theme #sk_omnibarSearchResult ul>li:nth-child(odd) {
    background: #282828;
}
.sk_theme #sk_omnibarSearchResult ul>li.focused {
    background: #ebdbb2;
}
`;

// vim: ft=javascript:et:sw=4:ts=4:sts=-1:fdm=marker:fmr={{{,}}}:
