const pluginScreen = document.getElementById('pluginScreen');

function displayPluginScreen(toggle) {
  pluginScreen.style.display = toggle ? 'block' : 'none';
}

window.addEventListener('message', ({ data }) => {
  const { action, value } = data;
  if (action === "toggleWindow") {
    displayPluginScreen(value === "true");
  }
});
