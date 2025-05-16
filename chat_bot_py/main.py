# from transformer_chatbot import TransformerChatBot

# bot = TransformerChatBot()

# while True:
#     user_input = input("Kamu: ")
#     if user_input.lower() == "keluar":
#         break
#     response = bot.ask(user_input)
#     print("Bot:", response)

from model_loader import load_qwen_model
from prompt_generator import build_prompt

def main():
    print("🧠 Qwen1.5-1.8B Inference Lokal")
    generator = load_qwen_model()

    while True:
        user_input = input("\n🧑 Kamu: ")
        if user_input.lower() in ["exit", "quit"]:
            print("👋 Sampai jumpa!")
            break

        prompt = build_prompt(user_input)

        result = generator(
            prompt,
            max_new_tokens=150,
            do_sample=True,
            temperature=0.7,
            top_k=50,
            top_p=0.95
        )

        response = result[0]["generated_text"].replace(prompt, "").strip()
        print(f"\n🤖 AI: {response}")

if __name__ == "__main__":
    main()
