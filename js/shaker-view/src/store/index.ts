import Vue from 'vue'
import Vuex from 'vuex'

import FileModule from './FileModule'

Vue.use(Vuex)

interface StoreType {
  fileModule: FileModule;
}

const store = new Vuex.Store<StoreType>({})
export default store
