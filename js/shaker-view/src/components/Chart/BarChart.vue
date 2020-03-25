<script lang="ts">
import { Component, Mixins, Prop, Vue } from 'vue-property-decorator'
import { Line, mixins } from 'vue-chartjs'

@Component
export default class BarChart extends Mixins(Line, mixins.reactiveProp) {
  @Prop() public chartData!: Chart.ChartData
  @Prop() public chartOptions!: Chart.ChartOptions

  mounted () {
    this.renderChart(this.chartData, this.chartOptions)
  }
}
</script>
