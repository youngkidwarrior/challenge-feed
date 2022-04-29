open Discord

module type Command = {
  let data: SlashCommandBuilder.t
  let execute: Interaction.t => Js.Promise.t<Message.t>
}

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

let onMessage = (message: Message.t) => {
  let channel = message->Message.getMessageChannel
  let channelId = channel->Channel.getChannelId
  channelId !== activeChannelId
    ? ()
    : {
        let hasAttachment = message->Message.getMessageAttachments->Collection.getSize > 0
        let hasEmbed = message->Message.getMessageEmbeds->Collection.getSize > 0
        let hasLink = message->Message.getMessageContent->Js.String2.includes("http")
        let isBot = message->Message.getMessageAuthor->User.getUserId === clientId
        let allowed = hasAttachment || hasEmbed || hasLink || isBot
        allowed ? () : message->Message.delete->ignore
      }
}

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

client->Client.on(#messageCreate(message => message->onMessage))

client->Client.on(#interactionCreate(interaction => interaction->onInteraction))

let token = envConfig["discordApiToken"]
client->Client.login(token)
