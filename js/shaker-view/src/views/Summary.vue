<template>
  <div class="container">
    <summary-view :source="parseResult"></summary-view>
  </div>
</template>

<script lang="ts">
import { Component, Prop, Vue } from 'vue-property-decorator'
import SummaryView from '../components/SummaryView.vue'
import { CsvResult } from '../model/CsvResult'

import { getModule } from 'vuex-module-decorators'
import FileModule from '../store/FileModule'

@Component({
  components: {
    SummaryView
  }
})
export default class Summary extends Vue {
  get parseResult () {
    const module = getModule(FileModule)
    console.log(module)
    return module.loadedFile
  }
}
</script>
