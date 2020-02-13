<template>
  <div class="hello">
    <h1>{{ summary }}</h1>
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

  get summary () {
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
h3 {
  margin: 40px 0 0;
}
ul {
  list-style-type: none;
  padding: 0;
}
li {
  display: inline-block;
  margin: 0 10px;
}
a {
  color: #42b983;
}
</style>
