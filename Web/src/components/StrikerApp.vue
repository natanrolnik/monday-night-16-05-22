<template>
  <div>
    <h1>Welcome to Striker!</h1>

    <div v-if="userId == null">
      <h2>
        Add your name to play with us!<br>
        (In the end, we'll raffle a book)
      </h2>
      <input v-model.trim="inputUserName" type="text" placeholder="Your name and last name"/>
      <button class="button" v-on:click="this.createUser()">Become a Star</button>
    </div>

    <div v-else>
      <div v-if="isRaffleIdle">
        <h2>Hello, {{ userName }}</h2>
        <button class="button" v-on:click="this.registerGoal()">I Scored a Goal!</button>
        <p>
        Goals so far: {{ goalsCount }}
        </p>
      </div>
      <div class="book-raffle" v-else>
        <h2>Book Raffle 📚</h2>
        <div class="candidate-name" v-if="candidateUserName != null" :style="{'background-color': raffleBackgroundColor}">
          <h3>{{ candidateUserName }}</h3>
        </div>
        <div class="winner" v-if="winnerUser != null">
          <div v-if="winnerUser.id == this.userId">
            Congrats, {{ winnerUser.name }}! You just won a book!
          </div>
          <div v-else>
            The winner is {{ winnerUser.name }}. Thanks for joining!
          </div>
        </div>
      </div>
    </div>

  </div>
</template>

<script>
const axios = require('axios')

export default {
  name: 'StrikerApp',
  mounted () {
    if (this.userId != null) {
      this.openRaffleSocket()
    }
  },
  data () {
    return {
      get userId () {
        return localStorage.getItem('striker-user-id')
      },
      set userId (value) {
        localStorage.setItem('striker-user-id', value)
      },
      get userName () {
        return localStorage.getItem('striker-user-name')
      },
      set userName (value) {
        localStorage.setItem('striker-user-name', value)
      },
      inputUserName: null,
      goalsCount: 0,
      isRaffleIdle: true,
      candidateUserName: null,
      winnerUser: null,
      openedSocket: false,
      raffleBackgroundColor: '#FFFFFF'
    }
  },
  methods: {
    httpBaseURL () {
      return 'http://localhost:8080'
      // return 'https://striker-api.eu.ngrok.io'
    },

    wsBaseURL () {
      return 'ws://localhost:8080'
      // return 'wss://striker-api.eu.ngrok.io'
    },

    async createUser () {
      try {
        const res = await axios.post(this.httpBaseURL() + '/users/new', { name: this.$data.inputUserName })
        this.userId = res.data.user.id
        this.userName = res.data.user.name
        this.openRaffleSocket()
      } catch (error) {
        alert('Creating user failed.\n' + (error.response.data.reason || error.message || 'No message') + '\nStatus code: ' + error.response.status)
      }
    },

    async registerGoal () {
      try {
        const config = {
          headers: {
            'X-Striker-User-Id': this.$data.userId
          }
        }
        const res = await axios.put(this.httpBaseURL() + '/goals/increment', {}, config)
        this.goalsCount = res.data.count
      } catch (error) {
        alert('Registering goal failed.\n' + (error.response.data.reason || error.message || 'No message') + '\nStatus code: ' + error.response.status)
      }
    },

    openRaffleSocket () {
      if (this.openedSocket) {
        return
      }

      this.openedSocket = true
      const connection = new WebSocket(this.wsBaseURL() + '/raffle/live')

      const self = this
      connection.onmessage = function (event) {
        const status = JSON.parse(event.data)

        if (self.winnerUser != null && self.winnerUser.id === self.userId) {
          return
        }

        if (status.idle != null) {
          self.isRaffleIdle = true
          self.raffleBackgroundColor = '#FFFFFF'
          self.winnerUser = null
          self.candidateUserName = null
        } else {
          self.isRaffleIdle = false

          if (status.running != null) {
            self.candidateUserName = status.running.candidate
            self.raffleBackgroundColor = 'rgb(' + status.running.color.r + ',' + status.running.color.g + ',' + status.running.color.b
          } else if (status.finished != null) {
            self.candidateUserName = null
            self.winnerUser = status.finished.winner
            self.raffleBackgroundColor = 'rgb(' + status.finished.color.r + ',' + status.finished.color.g + ',' + status.finished.color.b
          }
        }
      }
    }
  },
  props: {

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
input[type=text] {
  width: 200px;
  height: 40px;
  margin: 0px 2px;
  box-sizing: border-box;
}

.button {
  background-color: #42b983; /* Green */
  border: none;
  color: white;
  padding: 8px 32px;
  text-align: center;
  text-decoration: none;
  display: inline-block;
  font-size: 16px;
  box-shadow: 0 5px #666;
}

.button:hover {
  background-color: #297b56
}

.button:active {
  background-color: #205522;
  box-shadow: 0 5px #666;
  transform: translateY(2px);
}

.candidate-name {
  height: 75vh;
  line-height: 75vh;
  font-size: 60px;
}

.winner {
  height: 75vh;
  line-height: 75vh;
  font-size: 60px;
}

</style>
