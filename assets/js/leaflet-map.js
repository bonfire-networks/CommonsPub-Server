import L from "leaflet";

const template = document.createElement("template");
template.innerHTML = `
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.6.0/dist/leaflet.css"
    integrity="sha512-xwE/Az9zrjBIphAcBb3F6JVqxf46+CDLwfLMHloNu6KEQCAWi6HcDUbeOfBIptF7tcCzusKFjFw2yuvEpDL9wQ=="
    crossorigin=""/>
    <div style="height: 100%; min-height: 420px;">
        <slot />
    </div>
`;

class LeafletMap extends HTMLElement {
  constructor() {
    super();

    this.attachShadow({ mode: "open" });
    this.shadowRoot.appendChild(template.content.cloneNode(true));
    this.mapElement = this.shadowRoot.querySelector("div");

    var bounds = new L.LatLngBounds(JSON.parse(this.getAttribute("points")));

    this.map = L.map(this.mapElement).fitBounds(bounds);

    // this.map = L.map(this.mapElement).setView(
    //   [this.getAttribute("lat"), this.getAttribute("lng")],
    //   13
    // );

    L.tileLayer(
      "https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}",
      {
        attribution:
          'Map data &copy; <a href="https://www.openstreetmap.org/">OpenStreetMap</a> contributors, <a href="https://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="https://www.mapbox.com/">Mapbox</a>',
        maxZoom: 18,
        id: "mapbox/streets-v11",
        tileSize: 512,
        zoomOffset: -1,
        accessToken:
          "pk.eyJ1IjoibWF5ZWwiLCJhIjoiY2tlMmxzNXF5MGFpaDJ0bzR2M29id2EzOCJ9.QsmjD-zypsE0_wonLGCYlA",
      }
    ).addTo(this.map);

    this.defaultIcon = L.icon({
      iconUrl: "/images/logo_commonspub.png",
      iconSize: [64, 64],
    });
  }

  connectedCallback() {
    const markerElements = this.querySelectorAll("leaflet-marker");
    markerElements.forEach((markerEl) => {
      const lat = markerEl.getAttribute("lat");
      const lng = markerEl.getAttribute("lng");

      const marker = L.marker([lat, lng], {
        icon: this.defaultIcon,
      }).addTo(this.map);

      const popup = markerEl.getAttribute("popup");

      if (popup) {
        marker.bindPopup(popup).openPopup();

        marker.on("mouseover", function (e) {
          this.openPopup();
        });
        marker.on("mouseout", function (e) {
          this.closePopup();
        });
      }

      marker.addEventListener("click", (_event) => {
        markerEl.click();
      });

      const iconEl = markerEl.querySelector("leaflet-icon");
      const iconSize = [
        iconEl.getAttribute("width"),
        iconEl.getAttribute("height"),
      ];

      // iconEl.addEventListener("url-updated", (e) => {
      //   marker.setIcon(
      //     L.icon({
      //       iconUrl: e.detail,
      //       iconSize: iconSize,
      //       iconAnchor: iconSize,
      //     })
      //   );
      // });
    });
  }
}

window.customElements.define("leaflet-map", LeafletMap);
