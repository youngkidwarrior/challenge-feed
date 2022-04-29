open Discord

Env.createEnv()

let envConfig = Env.getConfig()
let envConfig = switch envConfig {
| Ok(config) => config
| Error(err) => err->Env.EnvError->raise
}

let activeChannelId = envConfig["discordChannelId"]
let clientId = envConfig["discordClientId"]
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
