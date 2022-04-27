<template>
  <div class="NutmegStars">
    <h1>Welcome to Nutmeg Stars!</h1>

    <div v-if="userId == null">
      <h2>Add your name to play with us!</h2>
      <h3>In the end, we'll raffle a book</h3>
      <input v-model.trim="inputUserName" type="text" placeholder="Your name and last name"/>
      <button v-on:click="this.createUser()" class="btn btn-primary">Become a Star</button>
    </div>

    <div v-else>
      <div v-if="isRaffleIdle">
        <h2>Hello, {{ userName }}</h2>
        <button v-on:click="this.registerNutmeg()" class="btn btn-primary">Nutmeg!</button>
        <p>
        Nutmegs so far: {{ nutmegsCount }}
        </p>
      </div>
      <div v-else>
        <h2>Book Raffle 📚</h2>
        <div v-if="candidateUserName != null">
          <h3>{{ candidateUserName }}</h3>
        </div>
        <div v-if="winnerUser != null">
          <div v-if="winnerUser.id == this.userId">
            Congrats, {{ winnerUser.name }}! You just won a book!
          </div>
          <div v-else>
            The winner is {{ winnerUser.name }}. Thanks for joining anyway!
          </div>
        </div>
      </div>
    </div>

  </div>
</template>

<script>
const axios = require('axios')

export default {
  name: 'NutmegStars',
  mounted () {
    if (this.userId != null) {
      this.openRaffleSocket()
    }
  },
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
      inputUserName: null,
      nutmegsCount: 0,
      isRaffleIdle: true,
      candidateUserName: null,
      winnerUser: null,
      openedSocket: false
    }
  },
  methods: {
    async createUser () {
      try {
        const res = await axios.post('http://localhost:8090/users/new', { name: this.$data.inputUserName })
        this.userId = res.data.user.id
        this.userName = res.data.user.name
        this.openRaffleSocket()
      } catch (error) {
        alert("Creating user failed. Make sure you're using a unique name.")
      }
    },
    async registerNutmeg () {
      try {
        const config = {
          headers: {
            'X-Nutmeg-User-Id': this.$data.userId
          }
        }
        const res = await axios.put('http://localhost:8090/nutmegs/increment', {}, config)
        this.nutmegsCount = res.data.count
      } catch (error) {
        alert('Something went wrong')
      }
    },
    openRaffleSocket () {
      if (this.openedSocket) {
        return
      }

      this.openedSocket = true
      const connection = new WebSocket('ws://localhost:8090/raffle/live')

      const self = this
      connection.onmessage = function (event) {
        const status = JSON.parse(event.data)

        if (self.winnerUser != null && self.winnerUser.id === self.userId) {
          return
        }

        if (status.idle != null) {
          self.isRaffleIdle = true
          self.winnerUser = null
          self.candidateUserName = null
        } else {
          self.isRaffleIdle = false

          if (status.running != null) {
            self.candidateUserName = status.running.candidate
          } else if (status.finished != null) {
            self.candidateUserName = null
            self.winnerUser = status.finished.winner
          }
        }
      }
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
