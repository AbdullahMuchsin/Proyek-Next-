from transformers import AutoModelForCausalLM, AutoTokenizer
import torch

class TransformerChatBot:
    def __init__(self, model_name="microsoft/DialoGPT-small"):
        print("Loading model...")
        self.tokenizer = AutoTokenizer.from_pretrained(model_name)
        self.model = AutoModelForCausalLM.from_pretrained(model_name)
        self.chat_history_ids = None  # Menyimpan history obrolan
        self.chat_history_ids_attention_mask = None  # Attention mask history

    def ask(self, question):
        # Encode input baru dengan token EOS
        new_input_ids = self.tokenizer.encode(question + self.tokenizer.eos_token, return_tensors='pt')

        # Gabungkan input baru dengan history percakapan sebelumnya
        if self.chat_history_ids is not None:
            bot_input_ids = torch.cat([self.chat_history_ids, new_input_ids], dim=-1)
            
            # Potong panjang input agar tidak melebihi panjang maksimum model
            max_length = self.model.config.n_positions
            if bot_input_ids.shape[1] > max_length:
                bot_input_ids = bot_input_ids[:, -max_length:]
        else:
            bot_input_ids = new_input_ids

        # Buat attention_mask baru dengan semua nilai 1 sesuai panjang bot_input_ids
        attention_mask = torch.ones_like(bot_input_ids)

        # Generate respons dari bot
        self.chat_history_ids = self.model.generate(
            bot_input_ids,
            attention_mask=attention_mask,
            max_length=1000,
            pad_token_id=self.tokenizer.eos_token_id,
            no_repeat_ngram_size=3,
            do_sample=True,
            top_k=50,
            top_p=0.95,
            temperature=0.7
        )

        # Ambil respons terakhir dari bot
        response = self.tokenizer.decode(
            self.chat_history_ids[:, bot_input_ids.shape[-1]:][0],
            skip_special_tokens=True
        )

        return response