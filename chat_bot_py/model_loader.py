from transformers import AutoTokenizer, AutoModelForCausalLM, pipeline

def load_qwen_model(model_id="distilgpt2"):
    tokenizer = AutoTokenizer.from_pretrained(model_id, trust_remote_code=True)
    model = AutoModelForCausalLM.from_pretrained(
        model_id,
        trust_remote_code=True,
        device_map="auto"  # Gunakan GPU kalau tersedia, atau CPU
    )
    
    generator = pipeline(
        "text-generation",
        model=model,
        tokenizer=tokenizer
    )

    return generator
