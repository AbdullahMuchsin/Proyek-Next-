from transformer_chatbot import TransformerChatBot

bot = TransformerChatBot()

while True:
    user_input = input("Kamu: ")
    if user_input.lower() == "keluar":
        break
    response = bot.ask(user_input)
    print("Bot:", response)
