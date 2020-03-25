<template>
  <section id="app" class="hero">
    <div class="hero-head">
      <shaker-nav-bar />
    </div>
    <div class="columns">
      <div class="column is-one-fifth">
        <side-menu />
      </div>
      <div class="column">
        <router-view/>
      </div>
    </div>
  </section>
</template>

<script lang="ts">
import { Component, Prop, Vue } from 'vue-property-decorator'
import ShakerNavBar from './components/NavBar/NavBar.vue'
import SideMenu from './components/SideMenu/SideMenu.vue'

@Component({
  components: {
    ShakerNavBar,
    SideMenu
  }
})
export default class App extends Vue {
}
</script>

<style lang="scss">
</style>
