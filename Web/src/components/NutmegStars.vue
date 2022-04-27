<template>
  <div class="NutmegStars">
    <div v-if="userId == null">
      <h1>Welcome to Nutmeg Stars!</h1>
      <h2>Add your name to play with us!</h2>
      <h3>In the end, we'll raffle a book</h3>
      <input v-model.trim="inputUserName" type="text" placeholder="Your name and last name"/>
      <button v-on:click="this.createUser()" class="btn btn-primary">Become a Star</button>
      </div>
    <div v-else>
      User exists!
    </div>
  </div>
</template>

<script>
const axios = require('axios')

export default {
  name: 'NutmegStars',
  data () {
    return {
      get userId () {
        return localStorage.getItem('nutmeg-stars-user-id')
      },
      set userId (value) {
        localStorage.setItem('nutmeg-stars-user-id', value)
      },
      get userName () {
        return localStorage.getItem('nutmeg-stars-user-name')
      },
      set userName (value) {
        localStorage.setItem('nutmeg-stars-user-name', value)
      },
      inputUserName: null
    }
  },
  methods: {
    async createUser () {
      try {
        const res = await axios.post('http://localhost:8090/users/new', { name: this.$data.inputUserName })
        this.userId = res.data.user.id
        this.userName = res.data.user.name
      } catch (error) {
        alert("Creating user failed. Make sure you're using a unique name.")
      }
      // axios.get('http://localhost:8090/hello')
    }
  },
  props: {
    msg: String
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
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
