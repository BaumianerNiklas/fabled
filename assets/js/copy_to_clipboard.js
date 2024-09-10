window.addEventListener("fabled:copy_to_clipboard", (event) => {
  navigator.clipboard.writeText(event.detail);
});
