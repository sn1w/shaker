<template>
  <div class="container">
    <summary-view :source="parseResult"></summary-view>
  </div>
</template>

<script lang="ts">
import { Component, Prop, Vue } from 'vue-property-decorator'
import SummaryView from '../components/SummaryView.vue'
import { CsvResult } from '../model/CsvResult'

@Component({
  components: {
    SummaryView
  }
})
export default class Summary extends Vue {
  get parseResult () {
    return this.$store.getters.loadedFile
  }
}
</script>
