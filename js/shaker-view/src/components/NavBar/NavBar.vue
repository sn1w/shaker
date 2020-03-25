<template>
  <nav class="navbar" role="navigation" aria-label="main navigation">
    <div id="navbarBasicExample" class="navbar-menu">
      <div class="navbar-start">
        <a class="navbar-item">
          Shaker
        </a>
        <p class="navbar-item">
          {{ fileName }}
        </p>
        <div class="file">
          <label class="file-label">
            <input class="file-input" type="file" name="resume" v-on:change="onFileChanged">
            <span class="file-cta">
              <span class="file-icon">
                <i class="fas fa-upload"></i>
              </span>
              <span class="file-label">
                Choose a file…
              </span>
            </span>
          </label>
        </div>
      </div>
    </div>
  </nav>
</template>

<script lang="ts">
import { Component, Prop, Vue } from 'vue-property-decorator'
import { getModule } from 'vuex-module-decorators'
import FileModule from '../../store/FileModule'

@Component
export default class ShakerNavBar extends Vue {
  get fileName () {
    return this.$store.getters.fileName
  }

  onFileChanged (event: Event) {
    if (event == null || event.target == null) {
      return
    }

    if (event.target instanceof HTMLInputElement) {
      if (event.target.files == null) {
        return
      }
      const file = event.target.files.item(0)
      if (file == null) {
        return
      }

      getModule(FileModule).parseNewFiles(file)
    }
  }
}
</script>
