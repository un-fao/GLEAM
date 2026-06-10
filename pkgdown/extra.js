document.addEventListener("DOMContentLoaded", function () {
  const zoomableImages = document.querySelectorAll(".module-figure-zoom");

  if (!zoomableImages.length) {
    return;
  }

  const overlay = document.createElement("div");
  overlay.className = "module-figure-lightbox";
  overlay.setAttribute("aria-hidden", "true");
  overlay.innerHTML =
    '<img alt="">' +
    '<button type="button" aria-label="Close enlarged image">&times;</button>';

  const overlayImage = overlay.querySelector("img");
  const closeButton = overlay.querySelector("button");

  function closeLightbox() {
    overlay.classList.remove("is-open");
    overlay.setAttribute("aria-hidden", "true");
    document.body.classList.remove("module-figure-lightbox-open");
    overlayImage.removeAttribute("src");
  }

  function openLightbox(image) {
    overlayImage.src = image.getAttribute("src");
    overlayImage.alt = image.getAttribute("alt") || "";
    overlay.classList.add("is-open");
    overlay.setAttribute("aria-hidden", "false");
    document.body.classList.add("module-figure-lightbox-open");
  }

  zoomableImages.forEach(function (image) {
    image.addEventListener("click", function () {
      openLightbox(image);
    });

    image.setAttribute("tabindex", "0");
    image.setAttribute("role", "button");
    image.setAttribute("aria-label", "Open enlarged figure");

    image.addEventListener("keydown", function (event) {
      if (event.key === "Enter" || event.key === " ") {
        event.preventDefault();
        openLightbox(image);
      }
    });
  });

  overlay.addEventListener("click", function (event) {
    if (event.target === overlay || event.target === closeButton) {
      closeLightbox();
    }
  });

  document.addEventListener("keydown", function (event) {
    if (event.key === "Escape" && overlay.classList.contains("is-open")) {
      closeLightbox();
    }
  });

  document.body.appendChild(overlay);
});
