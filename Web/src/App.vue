<template>
  <NutmegStars msg="Welcome to NutmegStars"/>
</template>

<script>
import NutmegStars from './components/NutmegStars.vue'

export default {
  name: 'App',
  components: {
    NutmegStars
  }
}
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
</style>
