import Vue from 'vue'
import VueRouter from 'vue-router'
import Summary from '../views/Summary.vue'
import Graphs from '../views/Graphs.vue'

Vue.use(VueRouter)

const routes = [
  {
    path: '/',
    name: 'Summary',
    component: Summary
  },
  {
    path: '/graphs',
    name: 'Graphs',
    component: Graphs
  }
]

const router = new VueRouter({
  routes
})

export default router
