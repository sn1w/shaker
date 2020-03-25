<template>
  <div class="graphs">
    <bar-chart :chart-data="chartData" />
  </div>
</template>

<script lang="ts">
import { Component, Prop, Vue } from 'vue-property-decorator'
import BarChart from '../components/Chart/BarChart.vue'

import { getModule } from 'vuex-module-decorators'
import FileModule from '../store/FileModule'

@Component({
  components: {
    BarChart
  }
})
export default class SideMenu extends Vue {
  get chartData () {
    const fileModule = getModule(FileModule)
    const loadedRecords = fileModule.loadedFile.records
    return {
      labels: loadedRecords.map(x => x.timestamp),
      datasets: [{
        label: 'aaa',
        data: loadedRecords.map(x => x.responseTime)
      }]
    }
  }
}
</script>
