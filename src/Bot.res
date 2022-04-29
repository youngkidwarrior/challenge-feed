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

let commands: Collection.t<string, module(Command)> = Collection.make()

commands
->Collection.set(Commands_Help.data->SlashCommandBuilder.getCommandName, module(Commands_Help))
->ignore

let onInteraction = (interaction: Interaction.t) => {
  !(interaction->Interaction.isCommand)
    ? Js.log("Not a command")
    : {
        let commandName = interaction->Interaction.getCommandName

        let command = commands->Collection.get(commandName)
        switch command->Js.Nullable.toOption {
        | None => Js.Console.error("Bot.res: Command not found")
        | Some(module(Command)) => Command.execute(interaction)->ignore
        }
      }
}

client->Client.on(
  #ready(
    () => {
      Js.log("Logged In")
    },
  ),
)

client->Client.on(#interactionCreate(interaction => interaction->onInteraction))

let token = envConfig["discordApiToken"]
client->Client.login(token)
