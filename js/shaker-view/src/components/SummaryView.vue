<template>
  <div class="summary-view">
    <table class="table">
      <thead>
        <tr>
          <td>Label</td>
          <td>Average</td>
          <td>Median</td>
          <td>Min</td>
          <td>Max</td>
          <td>90%</td>
          <td>95%</td>
          <td>Error</td>
        </tr>
      </thead>
      <tbody>
        <tr v-for="summary in summaries" v-bind:key="summary.label">
          <td>{{summary.label}}</td>
          <td>{{summary.average}}ms</td>
          <td>{{summary.median}}ms</td>
          <td>{{summary.min}}ms</td>
          <td>{{summary.max}}ms</td>
          <td>{{summary.ninetyPercentTile}}ms</td>
          <td>{{summary.ninetyFivePercentTile}}ms</td>
          <td>{{summary.errorRate}}%</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script lang="ts">
import { Component, Prop, Vue } from 'vue-property-decorator'
import { CsvResult, ResultRecord } from '../model/CsvResult'
import * as math from 'mathjs'

type SummaryRecord = {
  label: string;
  average: number;
  median: number;
  min: number;
  max: number;
  ninetyPercentTile: number;
  ninetyFivePercentTile: number;
  errorRate: number;
}

@Component
export default class SummaryView extends Vue {
  @Prop() private source!: CsvResult

  get summaries () {
    if (this.source.records.length === 0) {
      return ''
    }

    const records = this.source.records

    const groupByRecords = records.reduce((map: Map<string, ResultRecord[]>, record) => {
      const targetRecord = map.get(record.name)
      if (targetRecord === undefined) {
        map.set(record.name, [record])
      } else {
        targetRecord.push(record)
      }
      return map
    }, new Map<string, ResultRecord[]>())

    console.log(groupByRecords)

    const summaryRecords: SummaryRecord[] = []
    groupByRecords.forEach((v, k) => {
      let averageResponseTime = 0
      let errorRate = 0

      const responseTimes = v.map(record => record.responseTime)
      v.forEach(record => {
        averageResponseTime += record.responseTime
        if (record.status !== 200) {
          errorRate++
        }
      })

      averageResponseTime /= v.length
      errorRate /= v.length

      const median = math.median(responseTimes)
      const max = math.max(responseTimes)
      const min = math.min(responseTimes)
      const ninety = math.quantileSeq(responseTimes, 0.9)
      const ninetyFive = math.quantileSeq(responseTimes, 0.95)

      if (typeof ninety === 'number' && typeof ninetyFive === 'number') {
        summaryRecords.push({
          label: k,
          average: averageResponseTime,
          median: median,
          min: min,
          max: max,
          ninetyPercentTile: ninety,
          ninetyFivePercentTile: ninetyFive,
          errorRate: errorRate
        })
      }
    })

    return summaryRecords
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
</style>
