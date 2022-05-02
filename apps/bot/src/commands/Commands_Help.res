open Discord

let helpMessage = "```
This channel is used to post challenges in the SHE community. Please refrain fron
posting non-challenge related content.
If you would like to reply to a challenge, please create a thread!

Challenges must include a valid link to a challenge or they will be deleted.

Example: I did a backflip!
https://www.youtube.com/watch?v=dQw4w9WgXcQ

```"

let data =
  SlashCommandBuilder.make()
  ->SlashCommandBuilder.setName("help")
  ->SlashCommandBuilder.setDescription("Explain the Challenge Feed Channel Rules")

let execute = (interaction: Interaction.t) => {
  interaction->Interaction.reply(helpMessage, {"ephemeral": true})
}
