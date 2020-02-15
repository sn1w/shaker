import Vue from 'vue'
import Vuex from 'vuex'
import { CsvResult } from '@/model/CsvResult'

import { LOAD_NEW_FILE } from './mutation'

Vue.use(Vuex)

export default new Vuex.Store({
  state: {
    loadedFile: new CsvResult(),
    fileName: ''
  },
  mutations: {
    [LOAD_NEW_FILE] (state, payload) {
      state.loadedFile = payload.csvFile
      state.fileName = payload.fileName
    }
  },
  actions: {
    [LOAD_NEW_FILE] ({ commit, state }, file: File) {
      // this.fileName = file.name
      const reader = new FileReader()
      const fileBlob = file.slice(0, file.size, 'utf-8')
      reader.readAsText(fileBlob, 'utf-8')
      reader.onload = (event: ProgressEvent<FileReader>) => {
        if (event == null || event.target == null || event.target.result == null || event.target.result instanceof ArrayBuffer) {
          return
        }
        const columns = event.target.result.split('\n').map(line => line.split(','))
        const parseResult = CsvResult.Parse(columns)
        commit(LOAD_NEW_FILE, {
          csvFile: parseResult,
          fileName: file.name
        })
      }
    }
  },
  getters: {
    loadedFile: state => state.loadedFile,
    fileName: state => state.fileName
  },
  modules: {
  }
})
