<template>
  <GreenManPoster />
</template>

<script>
import GreenManPoster from "./components/GreenManPoster/GreenManPoster.vue"

export default {
  name: "App",
  components: { GreenManPoster },
};
</script>

<style>
.app {
  width: 100vw;
  min-height: 100vh;
  display: flex;
  /* justify-content: center; */
  align-items: center;
  background-color: black;
  background-size: contain;
  background-repeat: no-repeat;
  background-position: top center;
  padding: 0.5rem;
  box-sizing: border-box;
}
/* Make the app fill the viewport */
</style>
