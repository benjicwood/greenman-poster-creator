<template>
  <div class="poster-container">
    <!-- Background selector buttons -->
    <!-- <div class="background-selector">
      <button
        :class="{ active: selectedYear === '2026' }"
        @click="selectedYear = '2026'"
      >
        2026
      </button>
      <button
        :class="{ active: selectedYear === '2027' }"
        @click="selectedYear = '2027'"
      >
        2027
      </button>
    </div> -->
    <div
      class="poster-wrapper"
      ref="poster"
      @click.once="handleFirstInteraction"
    >
      <img
        class="poster-background"
        :src="backgroundSrc"
        alt="Festival Poster"
      />
      <BandGrid ref="bandGrid" :alwaysHighlight="isMobile && posterEmpty" />
      <!-- Click to start overlay -->
      <div v-if="isMobile && !hasStartedEditing" class="click-start">
        CLICK A SECTION TO START
      </div>
    </div>
  </div>

  <!-- Fixed bottom bar -->
  <div class="button-row" :class="{ hidden: controlsHidden }">
    <div class="button-actions">
      <button
        class="download-btn"
        :disabled="isExporting"
        @click="downloadPoster"
      >
        Export Poster
      </button>

      <button
        v-if="isMobile"
        :disabled="isExporting"
        class="share-btn"
        @click="sharePoster"
      >
        Share Poster
      </button>

      <button
        v-else
        class="copy-btn"
        :disabled="isExporting"
        @click="copyPoster"
      >
        Copy to Clipboard
      </button>
    </div>
  </div>

  <!-- Toggle button -->
  <button class="toggle-bar" @click="controlsHidden = !controlsHidden">
    {{ controlsHidden ? "▲" : "▼" }}
  </button>

  <!-- Toast -->
  <div v-if="toast.show" :class="['toast', toast.type]">
    {{ toast.message }}
  </div>
</template>

<script>
import BandGrid from "./BandGrid/BandGrid.vue";
import { toPng, toBlob } from "html-to-image";
// import bg2026 from "../../assets/background/atg26.png";
import bg2027 from "../../assets/background/greenman27.jpg";

export default {
  name: "GreenmanPoster",
  components: { BandGrid },

  data() {
    return {
      isHidden: false,
      selectedYear: "2027",
      isMobile: false,
      controlsHidden: false,
      isExporting: false,
      hasStartedEditing: false,
      toast: { show: false, message: "", type: "success" },
    };
  },

  computed: {
    posterEmpty() {
      const grid = this.$refs.bandGrid;
      if (!grid) return true;

      return Object.values(grid.days).every((day) => {
        return Object.values(day).every((value) => {
          return !value?.bands || value.bands.length === 0;
        });
      });
    },
    backgroundSrc() {
      return bg2027;
      // return this.selectedYear === "2026" ? bg2026 : bg2027;
    },
  },

  mounted() {
    document.body.style.backgroundColor = "#233E31";
    this.isMobile = /Android|iPhone|iPad|iPod/i.test(navigator.userAgent);
  },

  beforeUnmount() {
    document.body.style.backgroundColor = "";
  },

  methods: {
    showToast(message, type = "success", duration = 2500) {
      this.toast.show = true;
      this.toast.message = message;
      this.toast.type = type;
      setTimeout(() => (this.toast.show = false), duration);
    },

    handleFirstInteraction() {
      this.hasStartedEditing = true;
    },

    async withCleanPosterRender(fn) {
      const grid = this.$refs.bandGrid;
      if (!grid) return fn();

      await grid.runWithoutEditingUI(async () => {
        await fn();
      });
    },

    isFirefox() {
      return navigator.userAgent.toLowerCase().includes("firefox");
    },

    async downloadPoster() {
      if (this.isExporting) return;
      this.isExporting = true;

      try {
        await this.withCleanPosterRender(async () => {
          const node = this.$refs.poster;

          const isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent);
          const pixelRatio = isIOS ? 1 : 2;

          const dataUrl = await toPng(node, {
            quality: 1,
            cacheBust: true,
            backgroundColor: "#000",
            pixelRatio,
            skipFonts: this.isFirefox(),
          });

          const link = document.createElement("a");
          link.download = `greenman-poster-${this.selectedYear}.png`;
          link.href = dataUrl;
          link.click();

          this.showToast("Poster downloaded!");
        });
      } finally {
        this.isExporting = false;
      }
    },

    async sharePoster() {
      if (this.isExporting) return;
      this.isExporting = true;

      try {
        await this.withCleanPosterRender(async () => {
          const node = this.$refs.poster;

          const isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent);
          const pixelRatio = isIOS ? 1 : 2;

          const blob = await toBlob(node, {
            backgroundColor: "#000",
            pixelRatio,
            skipFonts: this.isFirefox(),
          });

          const file = new File(
            [blob],
            `greenman-poster-${this.selectedYear}.png`,
            {
              type: "image/png",
            },
          );

          if (navigator.canShare && navigator.canShare({ files: [file] })) {
            await navigator.share({
              files: [file],
              title: "Check out my festival poster!",
              text: `Made this Green Man Festival ${this.selectedYear} poster 🎶`,
            });

            this.showToast("Poster shared!");
          } else {
            const link = document.createElement("a");
            link.download = `greenman-poster-${this.selectedYear}.png`;
            link.href = URL.createObjectURL(blob);
            link.click();

            this.showToast(
              "Sharing not supported — poster downloaded instead.",
              "error",
            );
          }
        });
      } finally {
        this.isExporting = false;
      }
    },

    async copyPoster() {
      if (this.isExporting) return;
      this.isExporting = true;

      try {
        await this.withCleanPosterRender(async () => {
          const node = this.$refs.poster;

          const blob = await toBlob(node, {
            backgroundColor: "#000",
            pixelRatio: 2,
            skipFonts: this.isFirefox(),
          });

          await navigator.clipboard.write([
            new ClipboardItem({ "image/png": blob }),
          ]);

          this.showToast("Poster copied to clipboard!");
        });
      } finally {
        this.isExporting = false;
      }
    },
    // async uploadPosterToCloudinary(blob) {
    //   const form = new FormData();
    //   form.append("file", blob);
    //   form.append("upload_preset", "greenman-posters");
    //   form.append("tags", "greenman-gallery");

    //   const res = await fetch(
    //     "https://api.cloudinary.com/v1_1/dhqkcdjcx/image/upload",
    //     {
    //       method: "POST",
    //       body: form,
    //     },
    //   );

    //   if (!res.ok) {
    //     const err = await res.text();
    //     throw new Error(err);
    //   }

    //   return res.json();
    // },
  },
};
</script>

<style scoped lang="scss">
.poster-container {
  display: flex;
  // justify-content: center;
  align-items: center;
  min-height: 100vh;
}

.poster-wrapper {
  position: relative;
  display: inline-block;
  margin: auto;
}

.poster-background {
  display: block;
  max-width: 98vw;
  max-height: 100vh;
  width: auto;
  height: auto;
}

/* --- Floating Control Bar --- */
.button-row {
  position: fixed;
  bottom: 0;
  left: 50%;
  transform: translateX(-50%);
  z-index: 100;
  display: flex;
  justify-content: center;
  gap: 0.75rem;
  background: #B49EBA;
  padding: 0.75rem 1.25rem;
  border-radius: 12px 12px 0 0;
  backdrop-filter: blur(6px);
  font-family: sans-serif;
  transition:
    transform 0.3s ease,
    opacity 0.3s ease;

  &.hidden {
    transform: translate(-50%, 100%);
    opacity: 0;
    pointer-events: none;
  }
}

/* Toggle button */
.toggle-bar {
  font-family: sans-serif;
  border: 2px solid white;
  position: fixed;
  bottom: 4rem;
  // left: 50%;
  // transform: translateX(-50%);
  z-index: 101;
  background: #B49EBA;
  color: white;
  border-radius: 9999px;
  padding: 0.4rem 0.6rem;
  cursor: pointer;
  font-size: 1.2rem;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.25);
  transition:
    background 0.2s ease,
    bottom 0.3s ease;

  &:hover {
    background: #111f18;
  }
}

/* Move toggle up slightly when bar is hidden */
.button-row.hidden + .toggle-bar {
  bottom: 0.5rem;
}

/* --- Buttons --- */
.download-btn,
.share-btn,
.copy-btn {
  background: #B49EBA;
  border: 3px solid white;
  border-radius: 0;
  color: white;
  padding: 0.8rem 1.4rem;
  cursor: pointer;
  font-weight: bold;
  transition: background 0.2s ease;

  &:hover {
    background: #e73370;
  }
}

.download-btn,
.share-btn,
.copy-btn {
  &:disabled {
    opacity: 0.5;
    cursor: not-allowed;
    pointer-events: none;
  }
}

.share-btn:hover {
  background: #2563eb;
}

.copy-btn:hover {
  background: #059669;
}

/* --- Toast --- */
.toast {
  position: fixed;
  bottom: 2rem;
  left: 50%;
  transform: translateX(-50%);
  padding: 0.8rem 1.2rem;
  color: white;
  font-weight: bold;
  z-index: 1000;
  opacity: 0.95;
  transition: opacity 0.3s ease;

  &.success {
    background-color: #10b981;
  }

  &.error {
    background-color: #ef4444;
  }
}

@media (max-width: 620px) {
  .poster-container {
    align-items: flex-start;
  }

  .poster-wrapper {
    margin: 4px auto;
  }

  .button-row {
    top: auto;
    right: auto;
    left: auto;
    transform: none;
    flex-direction: row;
    justify-content: center;
    align-items: center;
    margin: 1.5rem auto 0 auto;
    background: transparent;
    box-shadow: none;
    padding: 0;
    bottom: 0;
    margin-bottom: 1rem;
  }
}

.click-start {
  position: absolute;
  top: 40%;
  left: 50%;
  transform: translate(-50%, -50%);
  color: white;
  font-size: 1.5rem;
  font-weight: bold;
  text-align: center;
  pointer-events: none;
  width: 90%;
}

.background-selector {
  position: absolute;
  top: 10px;
  left: 10px;
  z-index: 1000;
  display: flex;
  gap: 0.5rem; // space between buttons
  background: rgba(0, 0, 0, 0.5);
  padding: 0.5rem;
  border-radius: 6px;

  button {
    background: #333;
    color: white;
    border: 1px solid white;
    border-radius: 4px;
    padding: 0.5rem 1rem;
    cursor: pointer;
    font-family: sans-serif;
    font-weight: 600;
    transition: filter 0.2s;

    &:hover {
      filter: brightness(0.8); // darken on hover
    }

    &.active {
      background: #B49EBA; // highlight active year
      color: white;
      filter: none;
    }
  }

  // MOBILE: move to top-right
  @media (max-width: 768px) {
    left: auto;
    right: 10px;
  }
}

.button-row {
  flex-direction: column;
}

.button-actions {
  display: flex;
  gap: 0.75rem;
}

.gallery-link {
  color: rgba(255, 255, 255, 0.8);
  font-size: 0.85rem;
  text-decoration: none;
  text-align: center;
}

.gallery-link:hover {
  text-decoration: underline;
}
</style>
