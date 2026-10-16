
<template>
  <div :class="['band-grid', `band-grid-${slug}`]">
    <div class="headliners-row">
      <PosterRow
        :row="bands.headliner"
        :placeholder="`CLICK TO ADD ${day.toUpperCase()} HEADLINER`"
        :alwaysHighlight="alwaysHighlight || activeRowKey === 'headliner'"
        :showPlaceholderAlways="!posterStarted"
        :hideEditingUI="hideEditingUI"
        @click="$emit('open', slug, 'headliner', `${day} Headliner`)"
      />
    </div>

    <PosterRow
      class="lineup-row"
      :row="bands.lineup"
      :placeholder="`CLICK TO ADD ${day.toUpperCase()} BANDS`"
      :alwaysHighlight="alwaysHighlight || activeRowKey === 'lineup'"
      :showPlaceholderAlways="!posterStarted"
      :hideEditingUI="hideEditingUI"
      @click="$emit('open', slug, 'lineup', `${day} Lineup`)"
    />
  </div>
</template>

<script>
import PosterRow from "./PosterRow.vue";

export default {
  name: "DayGrid",
  components: { PosterRow },
  props: {
    day: { type: String, required: true },
    slug: { type: String, required: true },
    bands: { type: Object, required: true },
    alwaysHighlight: { type: Boolean, default: false },
    activeRowKey: { type: String, default: null },
    posterStarted: { type: Boolean, default: false },
    hideEditingUI: { type: Boolean, default: false },
  },
  emits: ["open"],
};
</script>

<style scoped lang="scss">
@use "../../../assets/scss/styles.scss";

.band-grid {
  height: 25%;
  box-sizing: border-box;
  margin: 0;
  flex-shrink: 0;
  display: flex;
  flex-direction: column;
  gap: 1%;
}

.headliners-row {
  display: grid;
  grid-template-columns: minmax(0, 1fr);
  flex: 0 0 30%;
  min-height: 0;
}

.lineup-row {
  flex: 1 1 0;
  min-height: 0;
}
</style>
