function removeItem(id) {
  fetch("/playlist/" + id, {
    method: "DELETE",
  }).then((response) => {
    console.log(response);
  });
  var item = document.getElementById(id);
  item.parentNode.removeChild(item);
  console.log(id);
}

function addItem() {
  fetch("/playlist/", {
    method: "POST",
    redirect: "follow",
  }).then((response) => {
    if (response.ok) location.reload();
    else console.log(response.body);
  });
}

function createPlaylist() {
  fetch("/playlist/create", {
    method: "POST",
    redirect: "follow",
  })
    .then((response) => response.text())
    .then((text) => {
      window.location.href = text;
    });
}
