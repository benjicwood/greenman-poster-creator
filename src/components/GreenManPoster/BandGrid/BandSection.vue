<template>
  <div
    :class="[
      position,
      size,
      'band-slot',
      { 'always-highlight': alwaysHighlight },
    ]"
    @click="$emit('click')"
  >
    <span v-if="band" ref="textEl" class="band-text" :class="weightClass">
      {{ band }}
    </span>
  </div>
</template>

<script>
export default {
  name: "BandSection",
  props: {
    band: String,
    position: String,
    size: String, // text-size-1..7
    weight: { type: [Number, String], default: 400 },
    alwaysHighlight: { type: Boolean, default: false },
  },

  computed: {
    weightClass() {
      return `fw-${Number(this.weight) || 400}`;
    },
  },

  mounted() {
    this.$nextTick(this.fitText);
    window.addEventListener("resize", this.fitText);
  },

  beforeUnmount() {
    window.removeEventListener("resize", this.fitText);
  },

  watch: {
    band() {
      this.$nextTick(this.fitText);
    },
    size() {
      this.$nextTick(this.fitText);
    },
    weight() {
      this.$nextTick(this.fitText);
    },
  },

  methods: {
    fitText() {
      const el = this.$refs.textEl;
      if (!el) return;

      const parent = el.parentElement;
      if (!parent) return;

      if (this.weight >= 800) {
        el.style.letterSpacing = "0.02em";
      }


      // Reset previous scaling
      el.style.transform = "scale(1)";
      el.style.transformOrigin = "center";

      // Ensure single line measurement
      el.style.whiteSpace = "nowrap";

      const paddingSafety = 8; // small buffer
      const maxWidth = parent.clientWidth - paddingSafety;

      // If already fits, do nothing
      if (el.scrollWidth <= maxWidth) return;

      const scale = maxWidth / el.scrollWidth;

      if (scale < 0.6) el.style.letterSpacing = "0em";

      // Prevent text becoming microscopic
      const clamped = Math.max(Math.min(scale, 1.15), 0.55);

      el.style.transform = `scale(${clamped})`;
    },
  },
};
</script>

<style scoped lang="scss">
.band-slot {
  display: flex;
  align-items: center;
  // justify-content: center;
  text-align: center;
  // overflow: hidden;
  padding: 0.35rem;
  box-sizing: border-box;
}

/* Core poster styling */
.band-text {
  display: inline-block; /* required for transform scaling */
  white-space: nowrap; /* no wrapping */
  text-transform: uppercase;
  letter-spacing: 0.04em;
  line-height: 1;
  color: inherit;
  font-family: "Greenman", sans-serif;
  font-synthesis: none; /* stops browser faking bold/italic */

  /* Base size (controlled further by .text-size-X classes) */
  // font-size: clamp(12px, 2.5cqw, 28px);

  transform-origin: center;
  transform: translateY(var(--y, 0em)) scale(var(--fitScale, 1));
}

/* Size presets from slider */
.text-size-1 .band-text {
  font-size: 11px;
}
.text-size-2 .band-text {
  font-size: 13px;
}
.text-size-3 .band-text {
  font-size: 15px;
}
.text-size-4 .band-text {
  font-size: 18px;
}
.text-size-5 .band-text {
  font-size: 22px;
}
.text-size-6 .band-text {
  font-size: 28px;
}
.text-size-7 .band-text {
  font-size: 36px;
}
.text-size-8 .band-text {
  font-size: 44px;
}

/* Font weights */
.fw-100 {
  font-weight: 100;
}
.fw-200 {
  font-weight: 200;
}
.fw-300 {
  font-weight: 300;
}
.fw-400 {
  font-weight: 400;
}
.fw-500 {
  font-weight: 500;
}
.fw-600 {
  font-weight: 600;
}
.fw-700 {
  font-weight: 700;
}
.fw-800 {
  font-weight: 800;
}
.fw-900 {
  font-weight: 900;
}

.fw-200.band-text {
  letter-spacing: 0.08em;
}

.always-highlight {
  border: solid #231740 1px !important;
}
</style>
