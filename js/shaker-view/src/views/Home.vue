<template>
  <div class="container">
    <h1>Showing {{fileName}}</h1>
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
export default class HomeComponent extends Vue {
  @Prop() private msg!: string

  public fileName = ''
  public parseResult: CsvResult = new CsvResult()

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
      this.fileName = file.name
      const reader = new FileReader()
      const fileBlob = file.slice(0, file.size, 'utf-8')
      reader.readAsText(fileBlob, 'utf-8')
      reader.onload = this.onFileLoadCompleted
    }
  }

  onFileLoadCompleted (event: ProgressEvent<FileReader>) {
    if (event == null || event.target == null || event.target.result == null) {
      return
    }

    if (typeof (event.target.result) === 'string') {
      this.parseCSVData(event.target.result)
    }
  }

  parseCSVData (csvText: string) {
    const columns = csvText.split('\n').map(line => line.split(','))
    this.parseResult = CsvResult.Parse(columns)
  }
}
</script>
