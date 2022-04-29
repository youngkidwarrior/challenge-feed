open Discord

let options: Client.clientOptions = {
  intents: ["GUILDS", "GUILD_MESSAGES"],
}

let client = Client.createDiscordClient(~options)

client->Client.on(
  #ready(
    () => {
      Js.log("Logged In")
    },
  ),
)

let token = envConfig["discordApiToken"]
client->Client.login(token)
