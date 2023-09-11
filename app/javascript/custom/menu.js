// メニュー操作

function addToggleListener(clickTargetId, actionTargetId, addingClassName) {
  let clickedTarget = document.querySelector(`#${clickTargetId}`);
  clickedTarget.addEventListener("click", function(event) {
    event.preventDefault();
    let actionTarget = document.querySelector(`#${actionTargetId}`);
    actionTarget.classList.toggle(addingClassName);
  });
};

document.addEventListener("turbo:load", function() {
  addToggleListener("hamburger", "navbar-menu", "collapse");
  addToggleListener("account", "dropdown-menu", "active");
});

