<template>
  <div class="poster-content">
    <!-- Thursday -->
    <div class="band-grid-thursday">
      <PosterRow
        class="thursday-headliner"
        :row="days.dayFour.headliner"
        placeholder="CLICK TO ADD THURSDAY HEADLINER(S)"
        @click="openEditor('dayFour', 'headliner', 'Thursday Headliner')"
        :alwaysHighlight="
          alwaysHighlight || isActiveRow('dayFour', 'headliner')
        "
        :showPlaceholderAlways="!posterStarted"
        :hideEditingUI="hideEditingUI"
      />

      <PosterRow
        class="thursday-second-row"
        :row="days.dayFour.secondRow"
        placeholder="CLICK TO ADD THURSDAY BANDS"
        @click="openEditor('dayFour', 'secondRow', 'Thursday Bands')"
        :alwaysHighlight="
          alwaysHighlight || isActiveRow('dayFour', 'secondRow')
        "
        :showPlaceholderAlways="!posterStarted"
        :hideEditingUI="hideEditingUI"
      />
    </div>
    <!-- Friday -->
    <DayGrid
      day="Friday"
      slug="dayOne"
      :bands="days.dayOne"
      :alwaysHighlight="alwaysHighlight"
      :activeRowKey="
        activeSlug === 'dayOne' && isEditorVisible ? activeRowKey : null
      "
      :posterStarted="posterStarted"
      :hideEditingUI="hideEditingUI"
      @open="openEditor"
    />

    <!-- Saturday -->
    <DayGrid
      day="Saturday"
      slug="dayTwo"
      :bands="days.dayTwo"
      :alwaysHighlight="alwaysHighlight"
      :activeRowKey="
        activeSlug === 'dayTwo' && isEditorVisible ? activeRowKey : null
      "
      :posterStarted="posterStarted"
      :hideEditingUI="hideEditingUI"
      @open="openEditor"
    />

    <!-- Sunday -->
    <DayGrid
      day="Sunday"
      slug="dayThree"
      :bands="days.dayThree"
      :alwaysHighlight="alwaysHighlight"
      :activeRowKey="
        activeSlug === 'dayThree' && isEditorVisible ? activeRowKey : null
      "
      :posterStarted="posterStarted"
      :hideEditingUI="hideEditingUI"
      @open="openEditor"
    />
  </div>

  <RowEditorTray
    :title="editorTitle"
    :row="isEditorVisible ? activeRow : null"
    :slug="activeSlug"
    :rowKey="activeRowKey"
    :placement="trayPlacement"
    :thursdayCoHeadliner="coHeadliner.thursday"
    :fridayCoHeadliner="coHeadliner.friday"
    :saturdayCoHeadliner="coHeadliner.saturday"
    @add-band="addBandToRow"
    @remove-band="removeBandFromRow"
    @move-band="moveBandInRow"
    @set-size="setRowSize"
    @set-weight="setRowWeight"
    @set-align="setRowAlign"
    @set-divider="setRowDivider"
    @co-headliner="handleCoHeadliner"
    @edit-band="editBandInRow"
    @close="closeEditor"
    @set-mode="setRowMode"
  />
</template>

<script>
import DayGrid from "./DayGrid.vue";
import PosterRow from "./PosterRow.vue";
import RowEditorTray from "../../BandSelectModal/RowEditorTray.vue";
import { trackBandSelected } from "../../../utils/analytics.js";

const makeRow = ({
  size = 5,
  weight = 500,
  maxBands = 30,
  minPx = 10,
  maxPx = 18,
  allowWrap = true,
  textAlign = "left",
  verticalAlign = "top",
  capSparseText = false,
  divider = "•",
  mode = "text",
} = {}) => ({
  bands: [],
  size,
  weight,
  maxBands,
  minPx,
  maxPx,
  allowWrap,
  textAlign,
  verticalAlign,
  capSparseText,
  divider,
  mode,
});

const makeStandardDay = () => ({
  headliner: makeRow({
    size: 6,
    weight: 900,
    maxBands: 4,
    minPx: 18,
    maxPx: 56,
    mode: "text",
  }),

  lineup: makeRow({
    size: 4,
    weight: 500,
    maxBands: 30,
    minPx: 10,
    maxPx: 24,
    mode: "text",
  }),
});

const makeThursday = () => ({
  headliner: makeRow({
    size: 7,
    weight: 900,
    maxBands: 4,
    minPx: 18,
    maxPx: 56,
    allowWrap: true,
    mode: "text",
    textAlign: "left",
  }),

  secondRow: makeRow({
    size: 5,
    weight: 500,
    maxBands: 12,
    minPx: 10,
    maxPx: 24,
    allowWrap: true,
    mode: "text",
    textAlign: "left",
  }),
});

export default {
  name: "BandGrid",
  components: { DayGrid, PosterRow, RowEditorTray },
  props: {
    alwaysHighlight: { type: Boolean, default: false },
  },

  data() {
    return {
      isEditorVisible: false,
      activeSlug: null,
      activeRowKey: null,
      editorTitle: "",
      isTrayMobile: false,
      hideEditingUI: false,

      days: {
        dayOne: makeStandardDay(),
        dayTwo: makeStandardDay(),
        dayThree: makeStandardDay(),
        dayFour: makeThursday(),
      },

      coHeadliner: {
        thursday: false,
        friday: false,
        saturday: false,
      },
    };
  },

  computed: {
    activeRow() {
      if (!this.activeSlug || !this.activeRowKey) return null;
      return this.days[this.activeSlug]?.[this.activeRowKey] || null;
    },

    trayPlacement() {
      if (this.activeSlug === "dayThree") return "top";
      if (this.activeSlug === "dayTwo") return "top";
      return "bottom";
    },

    posterStarted() {
      return Object.values(this.days).some((day) =>
        Object.values(day).some(
          (value) => Array.isArray(value?.bands) && value.bands.length > 0,
        ),
      );
    },
  },

  mounted() {
    this.updateTrayViewport();
    window.addEventListener("resize", this.updateTrayViewport);
  },

  beforeUnmount() {
    window.removeEventListener("resize", this.updateTrayViewport);
  },

  methods: {
    updateTrayViewport() {
      this.isTrayMobile = window.innerWidth <= 700;
    },

    openEditor(slug, rowKey, title) {
      if (this.hideEditingUI) return;
      this.activeSlug = slug;
      this.activeRowKey = rowKey;
      this.editorTitle = title;
      this.isEditorVisible = true;
    },

    editBandInRow({ index, id, name, source }) {
      const row = this.activeRow;
      if (!row || index < 0 || index >= row.bands.length) return;

      const normalizedName = this.normalizeBandName(name);

      row.bands[index] = {
        id: id || null,
        name: normalizedName,
        source: source || "custom",
      };

      // trackBandSelected("poster_band_added", {
      //   poster_day: this.getAnalyticsDayLabel(this.activeSlug),
      //   poster_row_key: this.activeRowKey,
      //   poster_row_label: this.getAnalyticsRowLabel(this.activeRowKey),
      //   band_id:
      //     id ||
      //     normalizedName.toLowerCase().replace(/[^a-z0-9]+/g, ""),
      //   band_name: normalizedName,
      //   band_source: source || "custom",
      // });
    },

    closeEditor() {
      this.isEditorVisible = false;
    },

    isActiveRow(slug, rowKey) {
      return (
        !this.hideEditingUI &&
        this.isEditorVisible &&
        this.activeSlug === slug &&
        this.activeRowKey === rowKey
      );
    },

    setRowMode(mode) {
      const row = this.activeRow;
      if (!row) return;

      row.mode = mode === "logos" ? "logos" : "text";
    },

    setPreviewMode(isPreview) {
      this.hideEditingUI = !!isPreview;
      if (isPreview) this.closeEditor();
    },

    async runWithoutEditingUI(fn) {
      const previous = this.hideEditingUI;
      this.hideEditingUI = true;
      this.closeEditor();

      await this.$nextTick();
      await new Promise((resolve) => requestAnimationFrame(resolve));

      try {
        return await fn();
      } finally {
        this.hideEditingUI = previous;
        await this.$nextTick();
      }
    },

    normalizeBandName(name) {
      return (name || "").trim().toUpperCase();
    },

    // getAnalyticsDayLabel(slug) {
    //   const map = {
    //     dayFour: "Thursday",
    //     dayOne: "Friday",
    //     dayTwo: "Saturday",
    //     dayThree: "Sunday",
    //   };

    //   return map[slug] || slug;
    // },

    getAnalyticsRowLabel(rowKey) {
      const map = {
        headliner: "headliner",
        coHeadliner: "co_headliner",
        secondRow: "main_support",
        lowerLineupOne: "lower_lineup_1",
        lowerLineupTwo: "lower_lineup_2",
        fourthRow: "wednesday_lower",
        lineup: "lineup",
      };

      return map[rowKey] || rowKey;
    },

    addBandToRow(band) {
      const row = this.activeRow;
      if (!row) return;
      if (row.bands.length >= row.maxBands) return;

      const normalizedName = this.normalizeBandName(band.name);
      if (!normalizedName || !this.activeRowKey) return;
      const normalizedId = band.id || null;
      const normalizedSource = band.source || "custom";

      // Prevent duplicates in the same row
      const alreadyExists = row.bands.some((existingBand) => {
        const existingName = this.normalizeBandName(existingBand.name);
        const existingId = existingBand.id || null;

        // Prefer ID match for catalog bands
        if (normalizedId && existingId) {
          return existingId === normalizedId;
        }

        // Fall back to normalized name match
        return existingName === normalizedName;
      });

      if (alreadyExists) {
        return;
      }

      row.bands.push({
        id: normalizedId,
        name: normalizedName,
        source: normalizedSource,
      });

      // trackBandSelected("poster_band_added", {
      //   poster_day: this.getAnalyticsDayLabel(this.activeSlug),
      //   poster_row_key: this.activeRowKey,
      //   poster_row_label: this.getAnalyticsRowLabel(this.activeRowKey),
      //   band_id:
      //     normalizedId ||
      //     normalizedName.toLowerCase().replace(/[^a-z0-9]+/g, ""),
      //   band_name: normalizedName,
      //   band_source: normalizedSource,
      // });
    },

    removeBandFromRow(index) {
      const row = this.activeRow;
      if (!row || index < 0 || index >= row.bands.length) return;

      row.bands.splice(index, 1);
    },

    moveBandInRow({ index, direction }) {
      const row = this.activeRow;
      if (!row) return;

      const target = direction === "up" ? index - 1 : index + 1;
      if (target < 0 || target >= row.bands.length) return;

      const copy = [...row.bands];
      [copy[index], copy[target]] = [copy[target], copy[index]];
      row.bands = copy;
    },

    setRowSize(size) {
      const row = this.activeRow;
      if (!row) return;
      row.size = Number(size) || 5;
    },

    setRowWeight(weight) {
      const row = this.activeRow;
      if (!row) return;
      row.weight = Number(weight) || 500;
    },

    setRowAlign(align) {
      const row = this.activeRow;
      if (!row) return;

      row.textAlign = align;
    },

    setRowDivider(divider) {
      const row = this.activeRow;
      if (!row) return;

      row.divider = divider;
    },

    handleCoHeadliner({ day, value }) {
      if (day === "Thursday") this.coHeadliner.thursday = value;
      if (day === "Friday") this.coHeadliner.friday = value;
      if (day === "Saturday") this.coHeadliner.saturday = value;
    },
  },
};
</script>

<style scoped lang="scss">
@use "../../../assets/scss/styles.scss";

.poster-content {
  position: absolute;
  top: 0;
  left: 50%;
  transform: translateX(-50%);
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
  gap: 1.2vh;
  box-sizing: border-box;
  padding-top: 15%;
  padding-bottom: 13%;
  padding-left: 4%;
  padding-right: 4%;
}
@media (max-width: 768px) {
  .poster-content {
    gap: 0.8vh;
  }
}

.band-grid-thursday {
  display: flex;
  flex-direction: column;
  width: 100%;
  align-items: stretch;
  gap: 1%;
  height: 12.5%;
  box-sizing: border-box;
}

.thursday-headliner {
  height: 56%;
}

.thursday-second-row {
  height: 44%;
}
</style>
