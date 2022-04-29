exception EnvError(string)

@module("dotenv") external createEnv: unit => unit = "config"
let nodeEnv = Node.Process.process["env"]

let env = name =>
  switch Js.Dict.get(nodeEnv, name) {
  | Some(value) => Ok(value)
  | None => Error(`Environment variable ${name} is missing`)
  }

let getConfig = () =>
  switch (
    env("DISCORD_API_TOKEN"),
    env("DISCORD_CLIENT_ID"),
    env("DISCORD_GUILD_ID"),
    env("DISCORD_CHANNEL_ID"),
  ) {
  // Got all vars
  | (Ok(discordApiToken), Ok(discordClientId), Ok(discordGuildId), Ok(discordChannelId)) =>
    Ok({
      "discordApiToken": discordApiToken,
      "discordClientId": discordClientId,
      "discordGuildId": discordGuildId,
      "discordChannelId": discordChannelId,
    })
  // Did not get one or more vars, return the first error
  | (Error(_) as err, _, _, _)
  | (_, Error(_) as err, _, _)
  | (_, _, Error(_) as err, _)
  | (_, _, _, Error(_) as err) => err
  }
