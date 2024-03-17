"""
Script to download and save an LLM (with its tokenizer)
into the directory used for the Enclave's Docker image.
"""

from transformers import AutoModelForCausalLM, AutoTokenizer

def download_model(model_name: str) -> None:
    """
    Downloads an LLM (with its tokenizer) from HuggingFace and
    saves it into the directory used for the Enclave's Docker image.
    """
    model = AutoModelForCausalLM.from_pretrained(model_name)
    tokenizer = AutoTokenizer.from_pretrained(model_name)

    tokenizer.save_pretrained('enclave_contents/model')
    model.save_pretrained('enclave_contents/model')

    return

if __name__ == '__main__':
    download_model('bigscience/bloom-560m')
