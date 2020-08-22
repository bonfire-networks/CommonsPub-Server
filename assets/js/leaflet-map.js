import L from "leaflet";

let ExtensionHooks = {};

ExtensionHooks.MapLeaflet = {
  mounted() {
    const view = this;

    const template = document.createElement("template");
    template.innerHTML = `
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.6.0/dist/leaflet.css"
    integrity="sha512-xwE/Az9zrjBIphAcBb3F6JVqxf46+CDLwfLMHloNu6KEQCAWi6HcDUbeOfBIptF7tcCzusKFjFw2yuvEpDL9wQ=="
    crossorigin=""/>
    <div style="height: 100%; min-height: 420px;">
        <slot />
    </div>`;

    const maybe_map_moved = function (e) {
      var bounds = createPolygonFromBounds(e.target, e.target.getBounds());
      console.log(bounds);
      view.pushEvent("bounds", bounds._latlngs);
    };

    /// Takes an L.latLngBounds object and returns an 8 point L.polygon.
    /// L.rectangle takes an L.latLngBounds object in its constructor but this only creates a polygon with 4 points.
    /// This becomes an issue when you try and do spatial queries in SQL because when the 4 point polygon is applied
    /// to the curvature of the earth it loses it's "rectangular-ness".
    /// The 8 point polygon returned from this method will keep it's shape a lot more.
    /// <param name="map">L.map object</param>
    /// <returns type="">L.Polygon with 8 points starting in the bottom left and finishing in the center left</returns>
    const createPolygonFromBounds = function (map, latLngBounds) {
      var center = latLngBounds.getCenter();
      var map_center = map.getCenter();
      var latlngs = [];

      latlngs.push(latLngBounds.getSouthWest()); //bottom left
      latlngs.push({ lat: latLngBounds.getSouth(), lng: center.lng }); //bottom center
      latlngs.push(latLngBounds.getSouthEast()); //bottom right
      latlngs.push({ lat: center.lat, lng: latLngBounds.getEast() }); // center right
      latlngs.push(latLngBounds.getNorthEast()); //top right
      latlngs.push({ lat: latLngBounds.getNorth(), lng: map_center.lng }); //top center
      latlngs.push(latLngBounds.getNorthWest()); //top left
      latlngs.push({ lat: map_center.lat, lng: latLngBounds.getWest() }); //center left

      return new L.polygon(latlngs);
    };

    class LeafletMap extends HTMLElement {
      constructor() {
        super();

        this.attachShadow({ mode: "open" });
        this.shadowRoot.appendChild(template.content.cloneNode(true));
        this.mapElement = this.shadowRoot.querySelector("div");

        var bounds = new L.LatLngBounds(
          JSON.parse(this.getAttribute("points"))
        );

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

        this.map.on("moveend", maybe_map_moved);
        this.map.on("zoomend", maybe_map_moved);

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
  },
};

Object.assign(liveSocket.hooks, ExtensionHooks);
