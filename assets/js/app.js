// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/_styles.scss";

// We must import the core script:
import "./core.js";

// Now import scripts from any extensions we are using:

// Editor - Prosemirror
// import "./editor_prosemirror.js";

// Editor - ck5
import "./editor_ck5.js";
