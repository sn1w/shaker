<template>
  <aside class="menu">
    <p class="menu-label">
      General
    </p>
    <ul class="menu-list">
      <li><router-link to="/">Summary</router-link></li>
      <li><router-link to="/graphs">Graphs</router-link></li>
    </ul>
  </aside>
</template>

<script lang="ts">
import { Component, Prop, Vue } from 'vue-property-decorator'

@Component
export default class SideMenu extends Vue {
  get currentView () {
    return this.$route.path
  }
}
</script>

<style lang="scss">
  .menu {
    padding: 10px;
  }
</style>
