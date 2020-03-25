import { Module, VuexModule, Mutation, Action } from 'vuex-module-decorators'
import { CsvResult } from '../model/CsvResult'
import store from '@/store'

interface LoadNewFilePayload {
  fileName: string;
  loadedFile: CsvResult;
}

@Module({
  dynamic: true,
  store: store,
  name: 'fileModule'
})
export default class FileModule extends VuexModule {
  private _loadedFile: CsvResult = new CsvResult()
  private _fileName = ''

  get loadedFile () {
    return this._loadedFile
  }

  get fileName () {
    return this._fileName
  }

  @Mutation
  loadNewFile (payload: LoadNewFilePayload) {
    this._loadedFile = payload.loadedFile
    this._fileName = payload.fileName
  }

  @Action
  parseNewFiles (file: File) {
    const reader = new FileReader()
    const fileBlob = file.slice(0, file.size, 'utf-8')
    reader.readAsText(fileBlob, 'utf-8')
    reader.onload = (event: ProgressEvent<FileReader>) => {
      if (event == null || event.target == null || event.target.result == null || event.target.result instanceof ArrayBuffer) {
        return
      }
      const columns = event.target.result.split('\n').map(line => line.split(','))
      const parseResult = CsvResult.Parse(columns)

      this.context.commit('loadNewFile', {
        fileName: file.name,
        loadedFile: parseResult
      })
    }
  }
}
