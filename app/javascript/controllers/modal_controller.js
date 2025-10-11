function closeModal() {
  const modal = document.querySelector("#modal");
  if (modal) modal.innerHTML = "";
}
window.closeModal = closeModal;
